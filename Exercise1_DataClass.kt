// ─────────────────────────────────────────────────────────────
// TASK 1 – At least two functions that operate on your data class
//           (e.g., validation, formatting)
// ─────────────────────────────────────────────────────────────

data class Grade(
    val subject: String,
    val score: Double,    // 0.0 – 100.0
    val maxScore: Double = 100.0
) {
    // Function 1 – VALIDATION
    // Returns true when the score is within the valid 0..maxScore range
    fun isValid(): Boolean {
        return score in 0.0..maxScore
    }

    // Function 2 – FORMATTING
    // Returns a human-readable summary of the grade, including a letter grade
    fun formatted(): String {
        val percentage = (score / maxScore) * 100
        val letter = when {
            percentage >= 90 -> "A"
            percentage >= 80 -> "B"
            percentage >= 70 -> "C"
            percentage >= 60 -> "D"
            else             -> "F"
        }
        return "$subject: ${"%.1f".format(score)}/$maxScore (${"%,.1f".format(percentage)}%) → $letter"
    }
}

fun main() {
    val grades = listOf(
        Grade("Mathematics", 88.0),
        Grade("Physics",     72.5),
        Grade("History",     105.0),   // invalid – above maxScore
        Grade("Art",         -5.0)     // invalid – below 0
    )

    println("=== Task 1 – Validation & Formatting ===\n")
    for (g in grades) {
        if (g.isValid()) {
            println(g.formatted())
        } else {
            println("${g.subject}: *** INVALID score (${g.score}) – skipped ***")
        }
    }
}
