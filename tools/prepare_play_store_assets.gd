extends SceneTree

## Produce the exact Google Play upload files from committed masters and genuine
## 1280x720 game captures. This directory is under assets/source/.gdignore so
## none of the store collateral is imported into or shipped with the game.

const SOURCE_ROOT := "res://assets/source/play-store"
const FINAL_ROOT := SOURCE_ROOT + "/final"


func _initialize() -> void:
	var output_dir := ProjectSettings.globalize_path(
		FINAL_ROOT + "/phone-screenshots")
	var mkdir_error := DirAccess.make_dir_recursive_absolute(output_dir)
	if mkdir_error != OK:
		push_error("Could not create Play Store output directory: %s" % mkdir_error)
		quit(1)
		return

	var jobs := [
		{
			"source": SOURCE_ROOT + "/masters/app-icon-master.png",
			"target": FINAL_ROOT + "/app-icon-512.png",
			"size": Vector2i(512, 512),
			"format": Image.FORMAT_RGBA8,
		},
		{
			"source": SOURCE_ROOT + "/masters/feature-graphic-master.png",
			"target": FINAL_ROOT + "/feature-graphic-1024x500.png",
			"size": Vector2i(1024, 500),
			"format": Image.FORMAT_RGB8,
		},
		{
			"source": SOURCE_ROOT + "/captures/01-home-1280x720.png",
			"target": FINAL_ROOT + "/phone-screenshots/01-home-1920x1080.png",
			"size": Vector2i(1920, 1080),
			"format": Image.FORMAT_RGB8,
		},
		{
			"source": SOURCE_ROOT + "/captures/02-bramble-swing-1280x720.png",
			"target": FINAL_ROOT + "/phone-screenshots/02-bramble-swing-1920x1080.png",
			"size": Vector2i(1920, 1080),
			"format": Image.FORMAT_RGB8,
		},
		{
			"source": SOURCE_ROOT + "/captures/03-spider-hub-1280x720.png",
			"target": FINAL_ROOT + "/phone-screenshots/03-spider-hub-1920x1080.png",
			"size": Vector2i(1920, 1080),
			"format": Image.FORMAT_RGB8,
		},
	]

	for job in jobs:
		if not _prepare_image(job):
			quit(1)
			return

	print("Prepared %d Google Play assets in %s" % [jobs.size(), output_dir])
	quit()


func _prepare_image(job: Dictionary) -> bool:
	var source_path: String = job["source"]
	var image := Image.load_from_file(ProjectSettings.globalize_path(source_path))
	if image == null or image.is_empty():
		push_error("Could not load Play Store source image: %s" % source_path)
		return false

	var target_size: Vector2i = job["size"]
	var scale := maxf(
		float(target_size.x) / float(image.get_width()),
		float(target_size.y) / float(image.get_height()),
	)
	var resized_size := Vector2i(
		ceili(float(image.get_width()) * scale),
		ceili(float(image.get_height()) * scale),
	)
	image.resize(resized_size.x, resized_size.y, Image.INTERPOLATE_LANCZOS)

	var crop_origin := Vector2i(
		(resized_size.x - target_size.x) / 2,
		(resized_size.y - target_size.y) / 2,
	)
	image = image.get_region(Rect2i(crop_origin, target_size))
	image.convert(job["format"])

	var target_path: String = job["target"]
	var save_error := image.save_png(ProjectSettings.globalize_path(target_path))
	if save_error != OK:
		push_error("Could not save Play Store asset %s: %s" % [
			target_path,
			save_error,
		])
		return false

	print("Prepared %s (%dx%d)" % [
		target_path,
		image.get_width(),
		image.get_height(),
	])
	return true
