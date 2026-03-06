// ─────────────────────────────────────────────────────────────
// TASK 2 – Use a higher-order function (map, filter, forEach)
//           on a list of your objects
// ─────────────────────────────────────────────────────────────

data class Grade(
    val subject: String,
    val score: Double,
    val maxScore: Double = 100.0
) {
    fun percentage() = (score / maxScore) * 100.0
    fun letterGrade() = when {
        percentage() >= 90 -> "A"
        percentage() >= 80 -> "B"
        percentage() >= 70 -> "C"
        percentage() >= 60 -> "D"
        else               -> "F"
    }
}

fun main() {
    val grades = listOf(
        Grade("Mathematics", 92.0),
        Grade("Physics",     74.0),
        Grade("Chemistry",   85.5),
        Grade("History",     58.0),
        Grade("Art",         95.0),
        Grade("Biology",     63.0)
    )

    println("=== Task 2 – Higher-Order Functions ===\n")

    // ── map ──────────────────────────────────────────────────
    // Transform each Grade into a formatted summary string
    val summaries: List<String> = grades.map { g ->
        "${"%-14s".format(g.subject)} | ${"%.1f".format(g.percentage())}% | ${g.letterGrade()}"
    }
    println("── map  →  formatted summaries ──")
    summaries.forEach { println("  $it") }

    // ── filter ───────────────────────────────────────────────
    // Keep only passing grades (score >= 60 %)
    val passing: List<Grade> = grades.filter { it.percentage() >= 60.0 }
    println("\n── filter  →  passing grades (≥ 60 %) ──")
    passing.forEach { println("  ${it.subject}: ${"%.1f".format(it.percentage())}%") }

    // ── forEach ──────────────────────────────────────────────
    // Print a personalised message for each failing grade
    val failing = grades.filter { it.percentage() < 60.0 }
    println("\n── forEach  →  improvement alerts for failing grades ──")
    failing.forEach { g ->
        println("  ⚠  ${g.subject} needs improvement! Current score: ${"%.1f".format(g.percentage())}%")
    }

    // ── bonus: map to compute average ────────────────────────
    val average = grades.map { it.percentage() }.average()
    println("\nOverall class average: ${"%.2f".format(average)}%")
}
