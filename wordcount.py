#!/usr/bin/env python3
"""
Word count script for Quarto documents
Excludes YAML frontmatter and code chunks
"""

import re

# Read the QMD file
qmd_file = "ctsemTutorial.qmd"
with open(qmd_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove YAML frontmatter (everything between first --- and second ---)
first_dash = content.find("---")
if first_dash != -1:
    remaining = content[first_dash + 3:]
    second_dash = remaining.find("---")
    if second_dash != -1:
        content = content[first_dash + second_dash + 6:]

# Remove code chunks (everything between ```{r...} and ```)
content = re.sub(r'```\{r[^}]*\}[\s\S]*?```', '', content)

# Remove inline code (backticks with content)
content = re.sub(r'`[^`]+`', '', content)

# Remove HTML comments
content = re.sub(r'<!--[\s\S]*?-->', '', content)

# Remove LaTeX comments (lines starting with %)
content = re.sub(r'^%.*$', '', content, flags=re.MULTILINE)

# Remove math equations (both inline $...$ and display $$...$$)
content = re.sub(r'\$\$[\s\S]*?\$\$', '', content)
content = re.sub(r'\$[^$]+\$', '', content)

# Remove markdown links but keep the text: [text](url) -> text
content = re.sub(r'\[([^\]]+)\]\([^\)]+\)', r'\1', content)

# Remove markdown images: ![alt](url)
content = re.sub(r'!\[[^\]]*\]\([^\)]+\)', '', content)

# Remove markdown headers (# symbols at start of line)
content = re.sub(r'^#+\s+', '', content, flags=re.MULTILINE)

# Remove citation markers like [@author2020]
content = re.sub(r'\[@[^\]]+\]', '', content)

# Clean up extra whitespace
content = re.sub(r'\s+', ' ', content)
content = content.strip()

# Count words (split by whitespace and count non-empty elements)
words = [w for w in content.split() if w]
word_count = len(words)

print("Word count (excluding code chunks, YAML header, math, citations):")
print(f"Total words: {word_count:,}")
print(f"Approximate pages (assuming 250 words/page): {word_count / 250:.1f}")
