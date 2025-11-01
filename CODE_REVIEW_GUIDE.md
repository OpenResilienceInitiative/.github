# Code Review Guide

> **📚 Organization README:** For a complete overview of contributing to ORISO Platform, see [README.md](./README.md)

This guide provides information about our code review standards and practices. **CodeRabbit** is configured to provide automated code reviews, but human reviewers should also follow these principles.

## Review Principles

### Be Constructive and Respectful
- Focus on the code, not the person
- Provide actionable feedback
- Acknowledge good practices and solutions

### Focus on Quality
- Ensure code solves the stated problem
- Verify edge cases are handled
- Confirm proper error handling

### Security Awareness
- Watch for sensitive data exposure
- Verify input validation is present
- Check authentication/authorization
- Look for SQL injection / XSS vulnerabilities

### Code Standards
- Follows project conventions
- No hardcoded values
- Proper naming conventions
- DRY principles followed
- Code is self-documenting

## What CodeRabbit Checks

CodeRabbit automatically reviews for:
- Code quality and best practices
- Security vulnerabilities
- Performance issues
- Documentation completeness
- Test coverage
- Code smells and anti-patterns

## Human Reviewer Responsibilities

While CodeRabbit handles automated checks, human reviewers should:
1. Verify business logic correctness
2. Ensure alignment with requirements
3. Review architecture decisions
4. Confirm integration points work correctly
5. Validate user experience (for UI changes)

## Review Process

1. **Initial Review** - CodeRabbit provides automated feedback
2. **Human Review** - Team members review business logic and design
3. **Address Feedback** - PR author addresses comments
4. **Approval** - Once all checks pass, approve and merge

## Common Issues to Watch For

- **Breaking Changes**: Ensure backward compatibility or document migration
- **Performance**: Large queries, N+1 problems, memory leaks
- **Testing**: Adequate test coverage for new/changed functionality
- **Documentation**: API docs, README updates, inline comments
- **Dependencies**: Unnecessary new dependencies or outdated versions

## Approval Criteria

A PR is ready to merge when:
- ✅ CodeRabbit checks pass
- ✅ All human review comments addressed
- ✅ CI/CD pipelines pass
- ✅ No blocking issues identified
- ✅ Required approvals obtained (see branch protection rules)

