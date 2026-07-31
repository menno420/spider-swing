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

## Where the profile's player-facing name comes from. A real spider with a
## usable name always wins (D-0031); a name is invented only when no usable real
## one exists, and an invented name must then name the science it borrows from.
const NAME_REAL := &"real"
const NAME_INVENTED := &"invented"
const NAME_ORIGINS: Array[StringName] = [NAME_REAL, NAME_INVENTED]

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
	&"weyman_1994": {
		"title": "Food deprivation and ballooning behaviour in Erigone spiders",
		"publisher": "Weyman, Entomologia Experimentalis et Applicata (1994)",
		"url": "https://onlinelibrary.wiley.com/doi/10.1111/j.1570-7458.1994.tb01846.x",
	},
	&"godwin_bond_2018": {
		"title": "Phylogeny of trapdoor spiders, with a description of the "
			+ "family Halonoproctidae",
		"publisher": "Godwin & Bond (2018)",
		"url": "https://pubmed.ncbi.nlm.nih.gov/29656103/",
	},
	&"amnh_cyclocosmia": {
		"title": "A revision of the trapdoor spider genus Cyclocosmia",
		"publisher": "American Museum Novitates 2580",
		"url": "https://digitallibrary.amnh.org/items/c802bd41-96a8-4535-aa0c-7cb3b1494816",
	},
}

const RECORDS := {
	&"classic": {
		"inspiration": COMPOSITE,
		"name_origin": NAME_REAL,
		"drawn_from": [
			{"name": "Araneus diadematus", "authority": "Clerck, 1757",
				"family": "Araneidae", "contributes": "the orb web and the body"},
		],
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
		"name_origin": NAME_REAL,
		"drawn_from": [
			{"name": "Lyssomanes viridis", "authority": "(Walckenaer, 1837)",
				"family": "Salticidae",
				"contributes": "this profile is that one species, not a blend"},
		],
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
		"name_origin": NAME_INVENTED,
		"drawn_from": [
			{"name": "Aphonopelma chalcodes", "authority": "",
				"family": "Theraphosidae",
				"contributes": "the heavy grounded body and desert burrow"},
			{"name": "Tliltocatl albopilosus", "authority": "",
				"family": "Theraphosidae",
				"contributes": "the dense curled hair"},
		],
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
		"name_origin": NAME_INVENTED,
		"drawn_from": [
			{"name": "Erigone atra", "authority": "",
				"family": "Linyphiidae",
				"contributes": "the ballooning launch, tiptoe and all"},
		],
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
			+ "show atmospheric electric fields can also trigger and help lift. "
			+ "The money spider Erigone atra is one of the most-recorded "
			+ "balloonists in Europe — a few millimetres long.",
		"game_adaptation":
			"A predictable reduced-gravity glide that the player steers after "
			+ "every release is fictional. Ballooning is one-way dispersal, not "
			+ "powered or steered flight.",
		"correction":
			"Ballooning is a behaviour shared across families and life stages, "
			+ "not the special ability of one species.",
		"sources": [&"morley_2018", &"cho_2021", &"weyman_1994"],
	},
	&"springtail": {
		"inspiration": FICTIONAL,
		"name_origin": NAME_INVENTED,
		"drawn_from": [
			{"name": "Ummidia", "authority": "Thorell, 1875",
				"family": "Halonoproctidae",
				"contributes": "the compact glossy body and hinged trapdoor"},
			{"name": "Cyclocosmia", "authority": "Ausserer, 1871",
				"family": "Halonoproctidae",
				"contributes": "the hardened abdominal disc"},
		],
		"inspired_by": "Cork-lid trapdoor spiders",
		"reference_name": "Ummidia",
		"reference_authority": "Thorell, 1875",
		"accepted_name": "",
		"family": "Halonoproctidae",
		"hook": "An invented spider, built on a real spider's armour.",
		"real_trait":
			"The look is taken from cork-lid trapdoor spiders: compact "
			+ "mygalomorphs with a hard, glossy carapace that build a silk-lined "
			+ "burrow closed by a hinged door and ambush from behind it. Their "
			+ "relatives in the genus Cyclocosmia go further — the abdomen ends "
			+ "in a hardened ribbed disc, and the spider backs down its burrow "
			+ "and plugs the shaft with it like a cork.",
		"game_adaptation":
			"Buckler is an invented spider — no animal carries this name. "
			+ "Surviving and rebounding from one rail impact is invented too. "
			+ "Even Cyclocosmia's disc is a door, not a shield: it seals a "
			+ "burrow behind the spider rather than protecting it from a hit.",
		"correction":
			"Armour is not why small animals survive falls. Low mass and high "
			+ "air resistance are — which is why a spider can drop from a height "
			+ "that would injure something much larger.",
		"sources": [&"wsc", &"godwin_bond_2018", &"amnh_cyclocosmia"],
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


## The scientific names a profile borrows from, formatted for display. An
## invented name must always resolve to at least one of these — that is the
## trade the player is owed for a name that is not a real animal's.
static func drawn_from_line(profile_id: StringName) -> String:
	var item := record(profile_id)
	if item.is_empty():
		return ""
	var parts := PackedStringArray()
	for entry: Dictionary in item["drawn_from"]:
		var authority := str(entry["authority"])
		var named := (
			str(entry["name"]) if authority.is_empty()
			else "%s %s" % [entry["name"], authority]
		)
		var contributes := str(entry.get("contributes", ""))
		parts.append(
			named if contributes.is_empty()
			else "%s — %s" % [named, contributes]
		)
	# Publishers and binomials both contain commas; a bullet keeps the list
	# readable when one profile combines several animals.
	return "   ·   ".join(parts)


static func has_invented_name(profile_id: StringName) -> bool:
	var item := record(profile_id)
	return not item.is_empty() and \
		StringName(item["name_origin"]) == NAME_INVENTED


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
