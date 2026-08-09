extends RefCounted
class_name PlaceholderTexture

static func make(color: Color, size: Vector2i = Vector2i(256, 256)) -> ImageTexture:
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)
