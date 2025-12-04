# Tool Call Formatting Rules

## Critical Tool Call Checklist

**BEFORE making ANY tool call, verify:**

1. ✓ All required parameters are identified
2. ✓ All required parameters have valid values (not empty, not placeholder)
3. ✓ Parameter values are appropriate for the tool's purpose
4. ✓ XML tags are properly formatted with opening and closing tags

## Common Tool Call Errors to Avoid

### Missing Required Parameters
❌ **WRONG:**
```
Using read_file without path parameter
Using execute_command without command parameter
Using search_files without regex parameter
```

✓ **CORRECT:**
```
Always include ALL required parameters with actual values
Check tool documentation for required vs optional parameters
Never submit a tool call with missing required parameters
```

### Example Code in Responses
❌ **WRONG:**
```
Showing example tool calls using actual XML tags like:
<read_file>
<path>example/path</path>
</read_file>
```
This will be EXECUTED as an actual tool call!

✓ **CORRECT:**
```
Use markdown code blocks with language tag
Describe tool format in plain text
Use pseudo-code or escaped examples
```

## Tool Call Validation Process

**STEP 1: Identify the Right Tool**
- What am I trying to accomplish?
- Which tool is designed for this purpose?

**STEP 2: Check Required Parameters**
- Read the tool's parameter list
- Identify which parameters are marked as "required"
- Verify I have or can determine values for all required parameters

**STEP 3: Validate Parameter Values**
- Are the values actual data (not placeholders like "path/to/file")?
- Are the values appropriate for the task?
- Do the values exist or make sense in the current context?

**STEP 4: Format the Tool Call**
- Use proper XML structure: `<tool_name><parameter_name>value</parameter_name></tool_name>`
- Include ALL required parameters
- Double-check opening and closing tags match

**STEP 5: Review Before Sending**
- Scan the complete tool call one more time
- Confirm no required parameters are missing
- Confirm no placeholder values remain

## When Discussing Tools with Users

**DO:**
- Describe tools and their purposes in plain text
- Use markdown code blocks to show structure
- Explain what parameters are needed

**DON'T:**
- Use actual XML tool tags in explanatory text
- Show "example" tool calls that will execute
- Format tool examples that the system will interpret as real calls

## Recovery from Tool Call Errors

If a tool call fails due to missing parameters:
1. Acknowledge the error clearly
2. Identify which parameter(s) were missing
3. Determine the correct value(s)
4. Retry with complete, valid parameters
5. Do NOT make the same error again in the same session

## Remember

**"Before you call, check them all"** - Required parameters must be present and valid.
