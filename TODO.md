TODO
-

# Version 1.0

- Allow using multiple columns to generate one variable
- Allow using strptime to parse date & time
- Allow regex column headers
- Allow case insensitive column headers
- Create parser for ActiveRecord models
- Deal with negative numbers
- Obsessively cover possible encoding issues in header and body
- Test that specifying parsers with procs works
- Consider what to do if error handler is not defined
- Test error handling in all blocks, not just `rows`
- Add flow control mechanism
  - Test that it works from `parsers`, `rows`, `import` & `errors`
  - Allow options rather than blocks for common error handling strategies
  - Better to catch all errors, or only explicit flow control errors?
- Bug fix: line_number is sometimes off by one (possibly only MalformedCSVError)
- Re-enable class documentation cop
- Add date parser
- Add date time parser
- Throw errors when using reserved column names (`unparsed` & `csv_string`)
- Allow runtime configuration
  - `column`, `import`, & `error`


# Version 2.0
