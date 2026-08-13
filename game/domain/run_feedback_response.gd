extends RefCounted
class_name RunFeedbackResponse
## One closed, local-only answer paired with an exact retained run record.
##
## It has no timestamp, identity, upload state, or free text. The paired record
## already owns the build, mode, difficulty, outcome, and performance context.

const SCHEMA_VERSION := 1
const FIRST_SESSION_RUN_LIMIT := 3
const QUESTION_DEATH_COMPREHENSION := &"death_comprehension_v1"
const ANSWER_KNEW_WHAT_TO_DO := &"knew_what_to_do"
const ANSWER_NOT_SURE_WHAT_TO_DO := &"not_sure_what_to_do"

var record_id: String = ""
var question_id: StringName = QUESTION_DEATH_COMPREHENSION
var answer_id: StringName = &""


static func create(
	record: String,
	question: StringName,
	answer: StringName,
) -> RunFeedbackResponse:
	if record.is_empty() or not question_is_supported(question) or \
			not answer_is_supported(answer):
		return null
	var response := RunFeedbackResponse.new()
	response.record_id = record
	response.question_id = question
	response.answer_id = answer
	return response


static func from_dictionary(data: Dictionary) -> RunFeedbackResponse:
	var source_schema := int(data.get("schema_version", 1))
	if source_schema < 1 or source_schema > SCHEMA_VERSION:
		return null
	return RunFeedbackResponse.create(
		str(data.get("record_id", "")),
		StringName(str(data.get("question_id", ""))),
		StringName(str(data.get("answer_id", ""))),
	)


static func question_is_supported(question: StringName) -> bool:
	return question == QUESTION_DEATH_COMPREHENSION


static func answer_is_supported(answer: StringName) -> bool:
	return answer in [ANSWER_KNEW_WHAT_TO_DO, ANSWER_NOT_SURE_WHAT_TO_DO]


func copy() -> RunFeedbackResponse:
	return RunFeedbackResponse.from_dictionary(to_dictionary())


func to_dictionary() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"record_id": record_id,
		"question_id": str(question_id),
		"answer_id": str(answer_id),
	}
