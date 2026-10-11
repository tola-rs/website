// WCAG contrast maths.

#let _linear(value) = {
  if value <= 0.04045 { value / 12.92 } else { calc.pow((value + 0.055) / 1.055, 2.4) }
}

#let _encoded(value) = {
  if value <= 0.0031308 { 12.92 * value } else { 1.055 * calc.pow(value, 1 / 2.4) - 0.055 }
}

#let _luminance(color) = {
  let hex = color.to-hex()
  let channel(at) = int(hex.slice(1 + at * 2, 3 + at * 2), base: 16) / 255
  0.2126 * _linear(channel(0)) + 0.7152 * _linear(channel(1)) + 0.0722 * _linear(channel(2))
}

/// Grey with equal contrast against both backgrounds.
#let balanced-grey(light-background, dark-background) = {
  let light = _luminance(light-background)
  let dark = _luminance(dark-background)
  let target = calc.sqrt((calc.max(light, dark) + 0.05) * (calc.min(light, dark) + 0.05)) - 0.05
  let value = _encoded(target) * 100%
  rgb(value, value, value)
}
