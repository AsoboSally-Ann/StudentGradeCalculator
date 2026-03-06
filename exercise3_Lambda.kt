// ─────────────────────────────────────────────────────────────
// TASK 3 – A lambda passed to a custom higher-order function
//           AND a collection operation (filter a list of items)
// ─────────────────────────────────────────────────────────────

data class Grade(
    val subject: String,
    val score: Double,
    val maxScore: Double = 100.0
) {
    fun percentage() = (score / maxScore) * 100.0
}

// ── Custom higher-order function ─────────────────────────────
// Accepts a list of grades AND a lambda (predicate) that decides
// which grades to process, then applies a transform lambda to each.
fun <R> processGrades(
    grades: List<Grade>,
    predicate: (Grade) -> Boolean,      // lambda 1 – filter condition
    transform: (Grade) -> R             // lambda 2 – what to do with each
): List<R> {
    return grades.filter(predicate).map(transform)
}

// ── Another custom higher-order function ─────────────────────
// Applies an action lambda to every grade and returns a report string.
fun gradeReport(
    grades: List<Grade>,
    action: (Grade) -> String           // lambda passed in by caller
): String {
    return grades.joinToString(separator = "\n") { "  " + action(it) }
}

fun main() {
    val grades = listOf(
        Grade("Mathematics", 92.0),
        Grade("Physics",     74.0),
        Grade("Chemistry",   85.5),
        Grade("History",     58.0),
        Grade("Art",         95.0),
        Grade("Biology",     63.0),
        Grade("English",     49.0)
    )

    println("=== Task 3 – Lambdas & Custom Higher-Order Functions ===\n")

    // ── Lambda passed to custom higher-order function ─────────
    // Find subjects where the student scored an A (≥ 90 %)
    val topSubjects: List<String> = processGrades(
        grades,
        predicate  = { it.percentage() >= 90.0 },          // lambda 1
        transform  = { "${it.subject} (${it.percentage().let { p -> "%.1f".format(p) }}%)" }  // lambda 2
    )
    println("── Top grades (A ≥ 90 %) via custom processGrades() ──")
    topSubjects.forEach { println("  ✔ $it") }

    // ── Collection operation: filter a list of items ──────────
    // Filter grades that need a resit (below 60 %)
    val resitList: List<Grade> = grades.filter { it.percentage() < 60.0 }
    println("\n── Collection filter  →  subjects requiring a resit (< 60 %) ──")
    resitList.forEach { g ->
        println("  ✘ ${g.subject}: ${"%.1f".format(g.percentage())}%")
    }

    // ── Lambda passed to gradeReport() ───────────────────────
    println("\n── Full report via custom gradeReport() with lambda ──")
    val report = gradeReport(grades) { g ->
        val pct  = g.percentage()
        val star = if (pct >= 90) " ★" else ""
        "${"%-14s".format(g.subject)} ${"%.1f".format(pct)}%$star"
    }
    println(report)
}
