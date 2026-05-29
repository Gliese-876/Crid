from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
ANDROID_RES = ROOT / "android" / "app" / "src" / "main" / "res"
WINDOWS_ICON = ROOT / "windows" / "runner" / "resources" / "app_icon.ico"

LIGHT_BG = "#DDE6FF"
VISUAL_CENTERING_BLEND = 0.22
ADAPTIVE_FOREGROUND_SCALE = 0.68
PRIMARY = "#4D73FF"
SECONDARY = "#43C6B9"
TERTIARY = "#8F68FF"
WARN = "#F6BA4B"
INK = "#17203A"
PAPER = "#FFFFFF"
RAIL = "#E9EEFF"
DARK_BG = "#18234A"


def adaptive_xml() -> str:
    return """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
    <monochrome android:drawable="@mipmap/ic_launcher_monochrome" />
</adaptive-icon>
"""


def colors_xml(*, night: bool = False) -> str:
    return f"""<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="window_background">{"#1C1B1F" if night else "#FFFBFE"}</color>
    <color name="ic_launcher_background">{DARK_BG if night else LIGHT_BG}</color>
</resources>
"""


def notification_xml() -> str:
    return """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M5,5 H19 Q20,5 20,6 V8 H4 V6 Q4,5 5,5 Z" />
    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M4,8 H6 V19 H4 Z M18,8 H20 V19 H18 Z M4,17 H20 V19 H4 Z" />
    <path
        android:fillColor="#FFFFFFFF"
        android:pathData="M7,10 H10 V13 H7 Z M11,10 H14 V13 H11 Z M15,10 H17 V13 H15 Z M7,14 H10 V16.5 H7 Z M11,14 H14 V16.5 H11 Z M15,14 H17 V16.5 H15 Z" />
</vector>
"""


def draw_calendar_layer(
    size: int,
    *,
    shadow: bool = False,
    monochrome: bool = False,
) -> Image.Image:
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    scale = size / 512

    def box(rect: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
        return tuple(round(value * scale) for value in rect)

    if shadow:
        draw.rounded_rectangle(
            box((124, 130, 368, 456)),
            radius=round(64 * scale),
            fill=(44, 54, 92, 30),
        )
        return image

    if monochrome:
        alpha = Image.new("L", (size, size), 0)
        alpha_draw = ImageDraw.Draw(alpha)
        alpha_draw.rounded_rectangle(
            box((124, 130, 368, 456)),
            radius=round(64 * scale),
            fill=160,
        )
        alpha_draw.rounded_rectangle(
            box((124, 130, 368, 228)),
            radius=round(64 * scale),
            fill=255,
        )
        alpha_draw.rectangle(box((124, 186, 368, 228)), fill=255)
        alpha_draw.rounded_rectangle(
            box((152, 254, 198, 408)),
            radius=round(23 * scale),
            fill=56,
        )
        alpha_draw.rounded_rectangle(
            box((220, 254, 292, 316)),
            radius=round(24 * scale),
            fill=244,
        )
        alpha_draw.rounded_rectangle(
            box((308, 254, 354, 378)),
            radius=round(24 * scale),
            fill=244,
        )
        alpha_draw.rounded_rectangle(
            box((220, 340, 292, 408)),
            radius=round(24 * scale),
            fill=244,
        )
        alpha_draw.ellipse(box((156, 158, 180, 182)), fill=0)
        alpha_draw.ellipse(box((312, 158, 336, 182)), fill=0)
        image = Image.new("RGBA", (size, size), (255, 255, 255, 255))
        image.putalpha(alpha)
        return image

    draw.rounded_rectangle(
        box((124, 130, 368, 456)),
        radius=round(64 * scale),
        fill=PAPER,
    )
    draw.rounded_rectangle(
        box((124, 130, 368, 228)),
        radius=round(64 * scale),
        fill=PRIMARY,
    )
    draw.rectangle(box((124, 186, 368, 228)), fill=PRIMARY)
    draw.rounded_rectangle(
        box((152, 254, 198, 408)),
        radius=round(23 * scale),
        fill=RAIL,
    )
    draw.rounded_rectangle(
        box((220, 254, 292, 316)),
        radius=round(24 * scale),
        fill=SECONDARY,
    )
    draw.rounded_rectangle(
        box((308, 254, 354, 378)),
        radius=round(24 * scale),
        fill=TERTIARY,
    )
    draw.rounded_rectangle(
        box((220, 340, 292, 408)),
        radius=round(24 * scale),
        fill=WARN,
    )
    draw.ellipse(box((156, 158, 180, 182)), fill="#263766")
    draw.ellipse(box((312, 158, 336, 182)), fill="#263766")
    return image


def centered_offset(layer: Image.Image, canvas_size: int) -> tuple[int, int]:
    alpha = layer.getchannel("A")
    bounds = alpha.getbbox()
    if bounds is None:
        return (0, 0)
    left, top, right, bottom = bounds
    x = round((canvas_size - (right - left)) / 2 - left)
    y = round((canvas_size - (bottom - top)) / 2 - top)
    return (x, y)


def translate_layer(layer: Image.Image, offset: tuple[int, int]) -> Image.Image:
    dx, dy = offset
    return layer.transform(
        layer.size,
        Image.Transform.AFFINE,
        (1, 0, -dx, 0, 1, -dy),
        resample=Image.Resampling.BICUBIC,
    )


def build_calendar_content(
    render_size: int,
    *,
    include_shadow: bool = True,
    monochrome: bool = False,
) -> Image.Image:
    rotation = -7
    scale = render_size / 512
    rotation_center = (round(246 * scale), round(293 * scale))

    calendar = draw_calendar_layer(render_size, monochrome=monochrome).rotate(
        rotation,
        resample=Image.Resampling.BICUBIC,
        center=rotation_center,
    )
    offset = centered_offset(calendar, render_size)

    content = Image.new("RGBA", (render_size, render_size), (0, 0, 0, 0))
    if include_shadow:
        shadow = draw_calendar_layer(render_size, shadow=True).rotate(
            rotation,
            resample=Image.Resampling.BICUBIC,
            center=rotation_center,
        ).filter(ImageFilter.GaussianBlur(radius=max(1, round(render_size * 0.006))))
        content.alpha_composite(translate_layer(shadow, offset))
    content.alpha_composite(translate_layer(calendar, offset))
    return content


def build_visual_centered_calendar_content(
    render_size: int,
    *,
    include_shadow: bool = True,
    monochrome: bool = False,
) -> Image.Image:
    content = build_calendar_content(
        render_size,
        include_shadow=include_shadow,
        monochrome=monochrome,
    )
    reference = Image.new("RGBA", (render_size, render_size), LIGHT_BG)
    reference.alpha_composite(build_calendar_content(render_size))
    offset_x, offset_y = visual_centroid_offset(reference)
    return translate_layer(
        content,
        (
            -round(offset_x * VISUAL_CENTERING_BLEND),
            -round(offset_y * VISUAL_CENTERING_BLEND),
        ),
    )


def scale_transparent_layer(layer: Image.Image, scale: float) -> Image.Image:
    if scale == 1:
        return layer
    width, height = layer.size
    scaled_width = round(width * scale)
    scaled_height = round(height * scale)
    scaled = layer.resize(
        (scaled_width, scaled_height),
        Image.Resampling.LANCZOS,
    )
    output = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    output.alpha_composite(
        scaled,
        (
            round((width - scaled_width) / 2),
            round((height - scaled_height) / 2),
        ),
    )
    return output


def draw_icon(size: int, *, round_mask: bool = False) -> Image.Image:
    render_size = size * 4
    content = build_visual_centered_calendar_content(render_size)
    image = Image.new("RGBA", (render_size, render_size), LIGHT_BG)
    image.alpha_composite(content)
    image = image.resize((size, size), Image.Resampling.LANCZOS)

    if round_mask:
        mask = Image.new("L", (size, size), 0)
        mask_draw = ImageDraw.Draw(mask)
        mask_draw.ellipse((0, 0, size - 1, size - 1), fill=255)
        rounded = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        rounded.alpha_composite(image)
        rounded.putalpha(mask)
        return rounded
    return image


def draw_adaptive_foreground(size: int) -> Image.Image:
    render_size = size * 4
    content = build_visual_centered_calendar_content(
        render_size,
        include_shadow=False,
    )
    return scale_transparent_layer(
        content,
        ADAPTIVE_FOREGROUND_SCALE,
    ).resize((size, size), Image.Resampling.LANCZOS)


def draw_monochrome_icon(size: int) -> Image.Image:
    render_size = size * 4
    content = build_visual_centered_calendar_content(
        render_size,
        include_shadow=False,
        monochrome=True,
    )
    return scale_transparent_layer(
        content,
        ADAPTIVE_FOREGROUND_SCALE,
    ).resize((size, size), Image.Resampling.LANCZOS)


def visual_centroid_offset(image: Image.Image) -> tuple[float, float]:
    rgba = image.convert("RGBA")
    width, height = rgba.size
    corners = [
        rgba.getpixel((0, 0))[:3],
        rgba.getpixel((width - 1, 0))[:3],
        rgba.getpixel((0, height - 1))[:3],
        rgba.getpixel((width - 1, height - 1))[:3],
    ]
    background = tuple(sum(c[index] for c in corners) / len(corners) for index in range(3))
    sx = sy = mass = 0.0
    for y in range(height):
        for x in range(width):
            red, green, blue, alpha = rgba.getpixel((x, y))
            contrast = (
                abs(red - background[0])
                + abs(green - background[1])
                + abs(blue - background[2])
            ) / 765
            pixel_mass = (alpha / 255) * contrast
            sx += x * pixel_mass
            sy += y * pixel_mass
            mass += pixel_mass
    center_x = (width - 1) / 2
    center_y = (height - 1) / 2
    return sx / mass - center_x, sy / mass - center_y


def subject_bounds_offset(image: Image.Image) -> tuple[float, float]:
    rgba = image.convert("RGBA")
    width, height = rgba.size
    background = rgba.getpixel((0, 0))[:3]
    left = width
    top = height
    right = 0
    bottom = 0
    for y in range(height):
        for x in range(width):
            red, green, blue, alpha = rgba.getpixel((x, y))
            contrast = (
                abs(red - background[0])
                + abs(green - background[1])
                + abs(blue - background[2])
            ) / 765
            if alpha < 240 or contrast < .045:
                continue
            left = min(left, x)
            top = min(top, y)
            right = max(right, x)
            bottom = max(bottom, y)
    center_x = (width - 1) / 2
    center_y = (height - 1) / 2
    return (left + right) / 2 - center_x, (top + bottom) / 2 - center_y


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def remove_if_exists(path: Path) -> None:
    if path.exists():
        path.unlink()


def main() -> None:
    write_text(ANDROID_RES / "values" / "colors.xml", colors_xml())
    write_text(ANDROID_RES / "values-night" / "colors.xml", colors_xml(night=True))
    remove_if_exists(ANDROID_RES / "drawable" / "ic_launcher_foreground.xml")
    remove_if_exists(ANDROID_RES / "drawable-night" / "ic_launcher_foreground.xml")
    remove_if_exists(ANDROID_RES / "drawable" / "ic_launcher_monochrome.xml")
    write_text(ANDROID_RES / "drawable" / "ic_stat_notification.xml", notification_xml())
    write_text(ANDROID_RES / "mipmap-anydpi-v26" / "ic_launcher.xml", adaptive_xml())
    write_text(ANDROID_RES / "mipmap-anydpi-v26" / "ic_launcher_round.xml", adaptive_xml())

    densities = {
        "mipmap-mdpi": (48, 108),
        "mipmap-hdpi": (72, 162),
        "mipmap-xhdpi": (96, 216),
        "mipmap-xxhdpi": (144, 324),
        "mipmap-xxxhdpi": (192, 432),
    }
    for folder, (legacy_size, adaptive_size) in densities.items():
        output = ANDROID_RES / folder
        output.mkdir(parents=True, exist_ok=True)
        draw_icon(legacy_size).save(output / "ic_launcher.png")
        draw_icon(legacy_size, round_mask=True).save(output / "ic_launcher_round.png")
        draw_adaptive_foreground(adaptive_size).save(
            output / "ic_launcher_foreground.png"
        )
        draw_monochrome_icon(adaptive_size).save(output / "ic_launcher_monochrome.png")

    bounds_x, bounds_y = subject_bounds_offset(draw_icon(192))
    if abs(bounds_x) > 20 or abs(bounds_y) > 20:
        raise RuntimeError(
            f"Icon subject bounds are off center by ({bounds_x:.2f}, {bounds_y:.2f}) px"
        )
    offset_x, offset_y = visual_centroid_offset(draw_icon(192))
    if abs(offset_x) > 14 or abs(offset_y) > 14:
        raise RuntimeError(
            f"Icon visual centroid is off center by ({offset_x:.2f}, {offset_y:.2f}) px"
        )

    icon_sizes = [16, 24, 32, 48, 64, 128, 256]
    ico_images = [draw_icon(size).convert("RGBA") for size in icon_sizes]
    WINDOWS_ICON.parent.mkdir(parents=True, exist_ok=True)
    ico_images[-1].save(WINDOWS_ICON, sizes=[(size, size) for size in icon_sizes])


if __name__ == "__main__":
    main()
