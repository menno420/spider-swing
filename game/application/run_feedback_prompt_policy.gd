extends RefCounted
class_name RunFeedbackPromptPolicy
## Pure first-session policy for one closed comprehension question.
##
## The policy consumes completed local evidence. It never infers an answer,
## transmits anything, or changes the run/progression lifecycle.

const MAX_ELIGIBLE_RUNS := RunFeedbackResponse.FIRST_SESSION_RUN_LIMIT
const QUESTION_TEXT := \
	"When this run ended, did you know what you should have done differently?"
const QUESTION_LINE_ONE := "WHEN THIS RUN ENDED, DID YOU KNOW"
const QUESTION_LINE_TWO := "WHAT YOU SHOULD HAVE DONE DIFFERENTLY?"


static func prompt_for(
	record: RunRecord,
	ledger: RunRecordLedger,
) -> Dictionary:
	if record == null or ledger == null or \
			not record.is_first_session_feedback_eligible() or \
			record.feedback_eligible_run_ordinal < 1 or \
			record.feedback_eligible_run_ordinal > MAX_ELIGIBLE_RUNS or \
			ledger.feedback_for_record(record.record_id) != null:
		return {}
	return {
		"record_id": record.record_id,
		"question_id": str(
			RunFeedbackResponse.QUESTION_DEATH_COMPREHENSION),
		"question": QUESTION_TEXT,
		"question_line_one": QUESTION_LINE_ONE,
		"question_line_two": QUESTION_LINE_TWO,
		"eligible_run_ordinal": record.feedback_eligible_run_ordinal,
		"eligible_run_limit": MAX_ELIGIBLE_RUNS,
		"yes_answer_id": str(
			RunFeedbackResponse.ANSWER_KNEW_WHAT_TO_DO),
		"yes_label": "YES — I KNEW",
		"no_answer_id": str(
			RunFeedbackResponse.ANSWER_NOT_SURE_WHAT_TO_DO),
		"no_label": "NO — NOT SURE",
	}
