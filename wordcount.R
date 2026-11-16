# Word count script for Quarto documents
# Excludes YAML frontmatter and code chunks

library(stringr)

# Read the QMD file
qmd_file <- "ctsemTutorial.qmd"
content <- readLines(qmd_file, warn = FALSE)
content <- paste(content, collapse = "\n")

# Remove YAML frontmatter (everything between first --- and second ---)
# Find the positions of the first two --- markers
first_dash <- str_locate(content, "---")[1, 1]
if (!is.na(first_dash)) {
  # Find the second --- after the first one
  remaining <- substr(content, first_dash + 3, nchar(content))
  second_dash <- str_locate(remaining, "---")[1, 1]
  if (!is.na(second_dash)) {
    # Remove everything up to and including the second ---
    content <- substr(content, first_dash + second_dash + 6, nchar(content))
  }
}

# Remove code chunks (everything between ```{r...} and ```)
# This regex matches code chunks including their options
content <- str_replace_all(content, "```\\{r[^}]*\\}[\\s\\S]*?```", "")

# Remove inline code (backticks with content)
content <- str_replace_all(content, "`[^`]+`", "")

# Remove HTML comments
content <- str_replace_all(content, "<!--[\\s\\S]*?-->", "")

# Remove LaTeX comments (lines starting with %)
content <- str_replace_all(content, "^%.*$", "", multiline = TRUE)

# Remove math equations (both inline $...$ and display $$...$$)
content <- str_replace_all(content, "\\$\\$[\\s\\S]*?\\$\\$", "")
content <- str_replace_all(content, "\\$[^$]+\\$", "")

# Remove markdown links but keep the text: [text](url) -> text
content <- str_replace_all(content, "\\[([^\\]]+)\\]\\([^\\)]+\\)", "\\1")

# Remove markdown images: ![alt](url)
content <- str_replace_all(content, "!\\[[^\\]]*\\]\\([^\\)]+\\)", "")

# Remove markdown headers (# symbols)
content <- str_replace_all(content, "^#+\\s+", "", multiline = TRUE)

# Remove citation markers like [@author2020] but keep the text
content <- str_replace_all(content, "\\[@[^\\]]+\\]", "")

# Clean up extra whitespace
content <- str_replace_all(content, "\\s+", " ")
content <- str_trim(content)

# Count words (split by whitespace and count non-empty elements)
words <- str_split(content, "\\s+")[[1]]
words <- words[words != ""]
word_count <- length(words)

cat("Word count (excluding code chunks, YAML header, math, citations):\n")
cat(sprintf("Total words: %d\n", word_count))
cat(sprintf("Approximate pages (assuming 250 words/page): %.1f\n", word_count / 250))
