# QA Test Verification Rule

## Critical QA Practice: Independent Test Verification

**MANDATORY:** When performing QA reviews (@qa agent), you MUST independently run all tests rather than trusting dev agent reports.

## Why This Matters

1. **Independent Verification**: QA's role is to provide independent validation, not rubber-stamp dev reports
2. **Catch Discrepancies**: Dev reports may be outdated, incomplete, or contain errors
3. **Real-Time State**: Tests run now reflect current code state, not historical reports
4. **Professional Standards**: Industry-standard QA practice requires independent verification

## Required Process for QA Reviews

When executing `*review {story}` or any QA assessment:

### Step 1: Always Run Tests Yourself

```
BEFORE writing QA Results, MUST execute:
<use_mcp_tool>
<server_name>iris-execute-mcp</server_name>
<tool_name>execute_unit_tests</tool_name>
<arguments>
{
  "test_spec": "Test.JSONSchema.TestValidator",
  "namespace": "HSCUSTOM"
}
</arguments>
</use_mcp_tool>
```

### Step 2: Compare Results with Dev Report

- Note any discrepancies between dev report and actual results
- If results differ, investigate why (code changes? environment? test updates?)
- Document any differences in QA Results section

### Step 3: Base Gate Decision on YOUR Test Results

- Gate decisions MUST be based on tests YOU ran, not dev reports
- Include test execution summary in QA Results with timestamp
- Reference YOUR test execution in evidence section of gate file

## What to Verify

For ObjectScript projects:
- ✓ Run `execute_unit_tests` for all test classes mentioned in story
- ✓ Verify pass/fail counts match or exceed dev agent claims
- ✓ Check for any new test failures not mentioned in dev report
- ✓ Confirm execution time is reasonable (no performance regressions)

For other projects:
- ✓ Run appropriate test commands (npm test, pytest, etc.)
- ✓ Verify coverage metrics independently
- ✓ Check for flaky tests or intermittent failures

## Gate File Evidence Section

Always include YOUR test execution results:

```yaml
evidence:
  tests_reviewed: {count from YOUR execution}
  test_execution:
    timestamp: "{when YOU ran tests}"
    passed: {YOUR results}
    failed: {YOUR results}
    total: {YOUR results}
  risks_identified: {YOUR assessment}
```

## Consequences of Skipping This Step

- ❌ Gate decisions based on stale information
- ❌ Missing test failures that occurred after dev completion
- ❌ Loss of QA independence and credibility
- ❌ Potential production issues from unverified code

## Exception: When Tests Cannot Run

Only skip independent test execution if:
1. Test infrastructure is unavailable (document in QA Results)
2. Story explicitly has no tests (e.g., documentation-only stories)
3. Tests require specific environment not accessible (document limitation)

In these cases:
- Document why tests could not be run independently
- Note this as a concern in QA Results
- Consider CONCERNS gate status if verification is blocked

## Remember

**"Trust, but verify"** - Your independent verification is what makes QA valuable.
