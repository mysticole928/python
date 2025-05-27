# Listing Modules Used in Python Scripts

Here are some ways to get a unique list of imported Python modules.

- Find all Python files
- Extract module names from both 'import' and 'from' statements
- Sort and remove duplicates
- Remove empty lines
- Provide a clean andunique list of module names

These methods catch basic imports but might not catch all complex import patterns (like multi-line imports or imports with 'as' aliases).

```zsh
find . -name "*.py" -exec grep '^import\|^from' {} \; \
| sed 's/from\s\+\([^ ]\+\)\s\+import.*/\1/g' \
| sed 's/import\s\+\([^ ]\+\).*/\1/g' | sort -u
```

## Multiple Imports on a Single Line

```zsh
find . -name "*.py" -exec grep '^import\|^from' {} \; | \
sed 's/from \([^ ]*\) import.*/\1/g' | \
sed 's/import //g' | \
tr ',' '\n' | \
sed 's/^ *//g' | \
sed 's/ *$//g' | \
sort -u
```

## Same Idea but using awk

```zsh
find . -name "*.py" -exec grep '^import\|^from' {} \; | \
awk '{if($1=="import") print $2; if($1=="from") print $2}' | \
sort -u
```

## Using awk, grep, and sort

```zsh
find . -name "*.py" -exec grep '^import\|^from' {} \; | \
awk '{
    if($1=="import") print $2
    if($1=="from") print $2
}' | \
sort -u | \
grep -v '^$'
```

