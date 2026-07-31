extends RefCounted
class_name SpiderBiologyCatalog
## Biological inspiration records for the playable profiles.
##
## Deliberately separate from SpiderCatalog. A taxonomy correction — a renamed
## genus, a moved family, a sharper mapping — must be able to change a record
## here without touching a profile id, a saved upgrade level, or one tuned
## number. Balance and biology version independently.
##
## Every record states four things and never blurs them: the game identity, what
## it is inspired by, what the animal actually does, and what this game invents.
## `inspiration` records how strong the claim is, so a composite is never
## presented as a photographed species.

## The inspiration is one accepted species and the art matches its diagnostics.
const SPECIES := &"species"
## The inspiration blends several relatives; no species-level claim is made.
const COMPOSITE := &"composite"
## The inspiration is a behaviour recorded across many families, not a taxon.
const BEHAVIOUR := &"behaviour"
## The name is invented. Real biology may still guide the art.
const FICTIONAL := &"fictional"
const INSPIRATION_TYPES: Array[StringName] = [
	SPECIES, COMPOSITE, BEHAVIOUR, FICTIONAL,
]

## Accepted names follow the World Spider Catalog; store the review date with
## them so a stale record is visible rather than silently trusted.
const NAME_AUTHORITY := "World Spider Catalog v27"
const REVIEWED_ON := "2026-07-31"

const SOURCES := {
	&"wsc": {
		"title": "World Spider Catalog, version 27",
		"publisher": "Natural History Museum Bern",
		"url": "https://wsc.nmbe.ch/",
	},
	&"nhm_webs": {
		"title": "Spider webs and silk",
		"publisher": "Natural History Museum, London",
		"url": "https://www.nhm.ac.uk/discover/spider-webs.html",
	},
	&"morley_2018": {
		"title": "Electric fields elicit ballooning in spiders",
		"publisher": "Morley & Robert, Current Biology (2018)",
		"url": "https://pubmed.ncbi.nlm.nih.gov/29983315/",
	},
	&"cho_2021": {
		"title": "Aerodynamics and Earth's electric field in spider ballooning",
		"publisher": "Cho et al. (2021)",
		"url": "https://pubmed.ncbi.nlm.nih.gov/33712884/",
	},
}

const RECORDS := {
	&"classic": {
		"inspiration": COMPOSITE,
		"inspired_by": "Garden orb-weavers (family Araneidae)",
		"reference_name": "Araneus diadematus",
		"reference_authority": "Clerck, 1757",
		"accepted_name": "",
		"family": "Araneidae",
		"hook": "Orb-weavers read the world through their own silk.",
		"real_trait":
			"Garden orb-weavers rebuild a vertical capture web, often daily, and "
			+ "wait in or beside it. They feel prey as vibration carried through "
			+ "the threads, and spin several kinds of silk from different glands: "
			+ "frame lines, sticky spiral, dragline, and egg sac.",
		"game_adaptation":
			"Continuous high-speed grappling, Reel-In, Anchor Burst and Dive Pull "
			+ "are invented movement systems. No orb-weaver travels by swinging "
			+ "from anchor to anchor.",
		"correction":
			"Spider does not mean orb web. Many spiders build no capture web at "
			+ "all and hunt by stalking or ambush.",
		"sources": [&"wsc", &"nhm_webs"],
	},
	&"skitter": {
		"inspiration": SPECIES,
		"inspired_by": "Magnolia green jumper",
		"reference_name": "Lyssomanes viridis",
		"reference_authority": "(Walckenaer, 1837)",
		"accepted_name": "Lyssomanes viridis",
		"family": "Salticidae",
		"hook": "Jumping spiders hunt by sight and trail a silk safety line.",
		"real_trait":
			"The magnolia green jumper is a slender, translucent green jumping "
			+ "spider of broadleaf foliage in the south-eastern United States. "
			+ "Like other salticids it stalks prey visually rather than trapping "
			+ "it, and pays out a dragline before it jumps.",
		"game_adaptation":
			"A smaller hitbox, quicker forward recovery and a weaker Burst are "
			+ "balance numbers. Burst is not a jump, and no rechargeable dash "
			+ "exists in the animal.",
		"correction":
			"Lyssomanes is long-legged and slender for a jumping spider. The "
			+ "stocky, short-legged salticid shape belongs to other genera.",
		"sources": [&"wsc"],
	},
	&"anchorite": {
		"inspiration": COMPOSITE,
		"inspired_by": "Burrowing mygalomorphs — tarantula and trapdoor body plans",
		"reference_name": "Theraphosidae and trapdoor families",
		"reference_authority": "",
		"accepted_name": "",
		"family": "Mygalomorphae",
		"hook": "Heavy-bodied spiders ambush from a silk-lined burrow.",
		"real_trait":
			"Terrestrial tarantulas and trapdoor spiders are robust, often "
			+ "long-lived mygalomorphs. They line a burrow or retreat with silk "
			+ "and strike at prey passing the entrance. Their fangs move roughly "
			+ "in parallel and drive downward rather than pinching together.",
		"game_adaptation":
			"Stronger Reel-In, a heavier fall and a more powerful Burst are "
			+ "tuning choices. Body mass gives no real spider a stronger line.",
		"correction":
			"This is a composite, not one photographed species — and a spider's "
			+ "size is no guide to how medically significant it is.",
		"sources": [&"wsc"],
	},
	&"ballooner": {
		"inspiration": BEHAVIOUR,
		"inspired_by": "Ballooning — silk dispersal recorded across many families",
		"reference_name": "",
		"reference_authority": "",
		"accepted_name": "",
		"family": "",
		"hook": "Spiders can leave the ground on silk. They are not flying.",
		"real_trait":
			"Ballooning is a dispersal behaviour seen across many spider "
			+ "families, mostly in small spiders and spiderlings. The spider "
			+ "climbs to an exposed point, raises its abdomen in a tiptoe "
			+ "posture and releases silk. Airflow carries it, and experiments "
			+ "show atmospheric electric fields can also trigger and help lift.",
		"game_adaptation":
			"A predictable reduced-gravity glide that the player steers after "
			+ "every release is fictional. Ballooning is one-way dispersal, not "
			+ "powered or steered flight.",
		"correction":
			"Ballooning is a behaviour shared across families and life stages, "
			+ "not the special ability of one species.",
		"sources": [&"morley_2018", &"cho_2021"],
	},
	&"springtail": {
		"inspiration": FICTIONAL,
		"inspired_by": "Cork-lid trapdoor spiders",
		"reference_name": "Ummidia",
		"reference_authority": "Thorell, 1875",
		"accepted_name": "",
		"family": "Halonoproctidae",
		"hook": "Springtail is a game name. Real springtails are not spiders.",
		"real_trait":
			"The look is taken from cork-lid trapdoor spiders: compact "
			+ "mygalomorphs with a hard, glossy carapace that build a silk-lined "
			+ "burrow closed by a hinged door and ambush from behind it.",
		"game_adaptation":
			"Surviving and rebounding from one rail impact is invented. A "
			+ "hardened carapace resists drying out and predators at the burrow "
			+ "door; it is not impact armour.",
		"correction":
			"Real springtails (Collembola) are six-legged hexapods, not "
			+ "arachnids, and jump with a tail-like furca. This profile borrows "
			+ "the name only.",
		"sources": [&"wsc"],
	},
}

const _INSPIRATION_LABELS := {
	SPECIES: "REAL SPECIES",
	COMPOSITE: "COMPOSITE",
	BEHAVIOUR: "REAL BEHAVIOUR",
	FICTIONAL: "FICTIONAL NAME",
}


static func has_record(profile_id: StringName) -> bool:
	return RECORDS.has(profile_id)


static func record(profile_id: StringName) -> Dictionary:
	if not RECORDS.has(profile_id):
		return {}
	return (RECORDS[profile_id] as Dictionary).duplicate(true)


static func inspiration_label(inspiration: StringName) -> String:
	return str(_INSPIRATION_LABELS.get(inspiration, "UNCLASSIFIED"))


## The italicised binomial plus its author, or an empty string when the record
## deliberately makes no species-level claim.
static func scientific_line(profile_id: StringName) -> String:
	var item := record(profile_id)
	if item.is_empty():
		return ""
	var name_text := str(item["reference_name"])
	if name_text.is_empty():
		return ""
	var authority := str(item["reference_authority"])
	if authority.is_empty():
		return name_text
	return "%s %s" % [name_text, authority]


static func sources_for(profile_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var item := record(profile_id)
	if item.is_empty():
		return result
	for source_id: StringName in item["sources"]:
		if not SOURCES.has(source_id):
			continue
		var source := (SOURCES[source_id] as Dictionary).duplicate(true)
		source["id"] = source_id
		result.append(source)
	return result


## One compact line for the Garage card. The classification travels with the
## claim so a composite can never read as a verified species at a glance.
static func garage_summary(profile_id: StringName) -> String:
	var item := record(profile_id)
	if item.is_empty():
		return ""
	return "INSPIRED BY · %s  ·  %s" % [
		item["inspired_by"],
		inspiration_label(StringName(item["inspiration"])),
	]
