# ⚙️ Backend PR Template

**Linked Issue:** # (e.g., #72)

## 📝 Summary
- What functionality did you build or update?
- What is the purpose of this change?

## ✅ Checklist
- [ ] Code adheres to architecture & naming conventions.
- [ ] Proper error handling implemented.
- [ ] Unit/integration tests passed.
- [ ] API contracts documented (Swagger/OpenAPI updated).
- [ ] No hardcoded credentials or secrets.
- [ ] Matrix API, federation (TLS/.well-known/SRV), and E2EE handling verified (if applicable)  

## 🧩 Database Changes
- [ ] Added new migration(s)
- [ ] Rollback and backfill tested successfully
- [ ] Linked migration scripts in Reference Links

## 🧪 Proof of Validation
Provide the commands, test logs, or screenshots that confirm migrations were applied and rolled back cleanly.

## 🔗 Reference Links

| Type | Link |
|------|------|
| 🧭 Design Doc | [Link to doc](https://...) |
| 🧠 Technical Spec | [Link to doc](https://...) |
| 🎥 Demo Video | [Loom / YouTube link](https://...) |
| 📘 Related Docs | [Documentation link](https://...) |

## 🧪 Testing Details
- Environment tested: [ ] Dev [ ] Stage [ ] Prod
- Postman/API test results attached.

## 💬 Notes
(Performance concerns, dependency updates, etc.)
