# Script to strip YAML frontmatter and code chunks from a Quarto document
# Usage: source("strip_qmd.R") or Rscript strip_qmd.R

library(stringr)

# Configuration
input_file <- "ctsemTutorial.qmd"
output_file <- "ctsemTutorial_text_only.qmd"  # Set to NULL to print to console instead

# Read the QMD file
cat("Reading file:", input_file, "\n")
lines <- readLines(input_file, warn = FALSE)

# Remove YAML frontmatter (everything between first --- and second ---)
# Look for lines starting with --- (ignoring whitespace) that are not commented
cat("Removing YAML frontmatter...\n")
first_dash_line <- NA
second_dash_line <- NA

for (i in seq_along(lines)) {
  line <- lines[i]
  # Trim leading whitespace to check if line starts with ---
  trimmed <- str_trim(line)
  
  # Skip commented lines (lines starting with #)
  if (str_detect(trimmed, "^#")) {
    next
  }
  
  # Check if line starts with ---
  if (str_detect(trimmed, "^---$")) {
    if (is.na(first_dash_line)) {
      first_dash_line <- i
    } else if (is.na(second_dash_line)) {
      second_dash_line <- i
      break
    }
  }
}

if (!is.na(first_dash_line) && !is.na(second_dash_line)) {
  # Remove lines from first dash to second dash (inclusive)
  lines <- lines[-(first_dash_line:second_dash_line)]
  cat(sprintf("  YAML frontmatter removed (lines %d-%d).\n", first_dash_line, second_dash_line))
} else if (!is.na(first_dash_line)) {
  cat("  Warning: Found opening --- but could not find closing --- for YAML frontmatter.\n")
} else {
  cat("  No YAML frontmatter found.\n")
}

# Convert back to single string
content <- paste(lines, collapse = "\n")

# Remove code chunks (everything between ```{r...} and ```)
cat("Removing code chunks...\n")
code_chunk_pattern <- "```\\{r[^}]*\\}[\\s\\S]*?```"
matches <- str_extract_all(content, code_chunk_pattern)[[1]]
num_chunks <- length(matches)
content <- str_replace_all(content, code_chunk_pattern, "")
cat(sprintf("  Removed %d code chunk(s).\n", num_chunks))

# Remove inline code (backticks with content) - optional, comment out if you want to keep inline code
# content <- str_replace_all(content, "`[^`]+`", "")

# Clean up: remove multiple blank lines (more than 2 consecutive newlines)
content <- str_replace_all(content, "\\n\\n\\n+", "\\n\\n")

# Trim whitespace at start and end
content <- str_trim(content)

# Output results
if (!is.null(output_file)) {
  writeLines(content, output_file)
  cat("\nCleaned content written to:", output_file, "\n")
  cat("Original file size:", file.info(input_file)$size, "bytes\n")
  cat("Cleaned file size:", nchar(content), "characters\n")
} else {
  cat("\n--- Cleaned Content ---\n\n")
  cat(content)
  cat("\n\n--- End of Content ---\n")
}

# Word count summary
words <- str_split(str_replace_all(content, "\\s+", " "), "\\s+")[[1]]
words <- words[words != ""]
word_count <- length(words)

cat("\nSummary:\n")
cat(sprintf("  Total words: %d\n", word_count))
cat(sprintf("  Approximate pages (250 words/page): %.1f\n", word_count / 250))
