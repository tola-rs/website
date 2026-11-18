use tola image

const GALLERY = 'config/gallery.toml'
const ATTACHMENT = r#'(?i)(?<url>https://github\.com/user-attachments/assets/[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12})(?=$|[\s"'>)])'#
const ATTACHMENT_HOSTS = [
    'github-production-user-asset-6210df.s3.amazonaws.com'
    'objects.githubusercontent.com'
    'private-user-images.githubusercontent.com'
    'user-images.githubusercontent.com'
]

def fail [message: string] {
    error make {msg: $message}
}

def form-link [fields: record, label: string]: nothing -> string {
    let link = ($fields | get -o $label | default '' | str trim)
    if $link !~ '^https://[^\s\\]+$' { fail $"Enter a public HTTPS link in ($label)." }
    let url = ($link | url parse)
    if ($url.host | is-empty) or ($url.username | is-not-empty) or ($url.password | is-not-empty) {
        fail $"Enter a public HTTPS link in ($label)."
    }
    $link
}

def download-screenshot [attachment: string]: nothing -> record {
    let response = (http get --full --raw --redirect-mode manual --max-time 30sec $attachment)
    let image = if $response.status == 200 {
        $response.body
    } else {
        let location = ($response.headers.response | where name =~ '(?i)^location$' | get -o 0.value)
        if $location == null { fail 'GitHub did not return a screenshot.' }
        let target = ($location | url parse)
        if $target.scheme != 'https' or $target.host not-in $ATTACHMENT_HOSTS {
            fail 'The screenshot redirected outside GitHub’s attachment hosts.'
        }
        http get --raw --redirect-mode error --max-time 30sec $location
    }

    if ($image | describe) != 'binary' { fail 'Upload a PNG, JPEG, or WebP screenshot.' }
    if ($image | bytes length) > 10_485_760 { fail 'The screenshot exceeds 10 MB.' }
    let metadata = try { $image | image metadata } catch {
        fail 'Upload a PNG, JPEG, or WebP screenshot.'
    }
    let extension = match $metadata.mime {
        'image/png' => 'png'
        'image/jpeg' => 'jpg'
        'image/webp' => 'webp'
        _ => { fail 'Upload a PNG, JPEG, or WebP screenshot.' }
    }
    { image: $image, extension: $extension }
}

def prepare-gallery [issue: record, comment: string, alt: string]: nothing -> string {
    let name = ($issue.title | parse --regex '^\[Theme\] +(?<name>.+)$' | get -o 0.name | default '' | str trim)
    if ($name | is-empty) { fail 'Put the theme name after [Theme] in the issue title.' }

    let fields = ($issue.body | default ''
        | parse --regex '(?ms)^### (?<label>[^\r\n]+)\r?\n(?<value>.*?)(?=^### |\z)'
        | transpose --header-row --as-record)
    if ($fields | is-empty) { fail 'Use the theme submission form to open the issue.' }
    let repo = (form-link $fields 'Repository URL')
    let demo = (form-link $fields 'Live demo URL')
    let description = ($fields | get -o 'Description (English)' | default '' | str trim)
    if $description in ['' '_No response_'] { fail 'Add an English description to the issue.' }

    let config = (open --raw $GALLERY | decode utf-8)
    let entries = ($config | from toml | get -o options.theme-gallery.entries | default [])
    let source = ($repo | str trim --right --char '/')
    if ($entries | any {|entry| ($entry.repo | str trim --right --char '/') == $source }) {
        fail 'This repository already has an entry in the gallery.'
    }

    let uploaded = ($comment | lines | skip 1 | str join "\n" | parse --regex $ATTACHMENT | get -o 0.url)
    let submitted = ($fields | get -o Screenshot | default '' | parse --regex $ATTACHMENT | get -o 0.url)
    let attachment = ($uploaded | default $submitted)
    if $attachment == null { fail 'Attach a screenshot to the issue or to the /accept-theme comment.' }
    let screenshot = (download-screenshot $attachment)
    let filename = $"submission-($issue.number).($screenshot.extension)"
    let path = ('static/web-assets/themes' | path join $filename)
    let entry = {
        name: $name
        description: $description
        repo: $repo
        demo: $demo
        screenshot: $"/assets/themes/($filename)"
        alt: (if ($alt | is-empty) { $"($name) demo home page" } else { $alt })
    }
    let updated = $"($config | str trim --right)\n\n[[options.theme-gallery.entries]]\n($entry | to toml)"
    $updated | from toml | ignore
    $screenshot.image | save $path
    $updated | save --force $GALLERY
    $path
}

def main [] {
    let event = (open $env.GITHUB_EVENT_PATH)
    let approval = ($event.comment.body | lines | get -o 0 | default ''
        | parse --regex '^/accept-theme(?:[ \t]+(?<alt>.*))?$' | get -o 0)
    if $approval == null { return }

    let repo = $env.GITHUB_REPOSITORY
    let commenter = $event.comment.user.login
    let permission = (^gh api $"repos/($repo)/collaborators/($commenter)/permission" | from json | get permission)
    if $permission not-in ['admin' 'maintain' 'write'] { return }

    let issue = $event.issue
    let base = $event.repository.default_branch
    let branch = $"theme-issue-($issue.number)"
    let existing = (^gh pr list --repo $repo --head $branch --base $base --state all --limit 1 --json url | from json | get -o 0.url)
    if $existing != null {
        $"Gallery pull request: ($existing)\n" | save --append $env.GITHUB_STEP_SUMMARY
        return
    }

    # Reuse a branch from an earlier run if the reply still needs to be posted.
    let remote = (^git ls-remote --exit-code --heads origin $"refs/heads/($branch)" | complete)
    match $remote.exit_code {
        0 => {}
        2 => {
            let alt = ($approval.alt? | default '' | str trim)
            let image = (prepare-gallery $issue $event.comment.body $alt)
            ^git config user.name 'github-actions[bot]'
            ^git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
            ^git add -- $GALLERY $image
            ^git commit -m $"gallery: add theme from issue #($issue.number)"
            ^git push origin $"HEAD:refs/heads/($branch)"
        }
        _ => { fail ($remote.stderr | str trim) }
    }

    let query = ({quick_pull: 1, title: $issue.title, body: $"Closes #($issue.number)."} | url build-query)
    let url = $"($env.GITHUB_SERVER_URL)/($repo)/compare/($base | url encode --all)...($branch)?($query)"
    let link = (['[Open the gallery pull request](' $url ')'] | str join)
    let marker = $"<!-- ($branch) -->"
    let posted = (^gh api $"repos/($repo)/issues/($issue.number)/comments?per_page=100" --paginate --slurp
        | from json | flatten
        | any {|comment| $comment.user.login == 'github-actions[bot]' and ($comment.body | str contains $marker) })
    if not $posted {
        let reply = $"($marker)\n\nThe gallery entry is ready for review. ($link)"
        ^gh issue comment $issue.number --repo $repo --body $reply
    }
    $"($link)\n" | save --append $env.GITHUB_STEP_SUMMARY
}
