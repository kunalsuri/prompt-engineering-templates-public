
✅ Best Possible Sequence (Full Safe Workflow)

Short version: you’ll never get a 100% guarantee, but you can have a very strong, low-friction “safety gate” that you run on every AI-generated change before you execute it.

Below is a minimal but robust prompt you can give to your agent for TS/JS/Node code, plus a few lightweight local checks to combine with it.

1. ./safety-audit.sh

2. npm install --ignore-scripts

3. npm audit --production

4. npm run typecheck

5. npm run lint

6. Run Safety Gate LLM prompt

7. Only then run npm install (full) if needed

8. Finally run the app


