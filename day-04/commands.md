# Day 4 — Azure Repos and branching

Notes: [notes.md](notes.md). Replace `XX` with your seat (example `u03`). Login `buXX@attt21.onmicrosoft.com`.

| Item | Value |
|------|--------|
| Org | [https://dev.azure.com/org-bicep](https://dev.azure.com/org-bicep) |
| Project | `bicep-aug26` (already exists — do not create another project) |
| Your repo | `iac-uXX` (open if present; create only if missing) |
| Course folder (lab VM) | `/home/buXX/Azure-Bicep-with-Azure-DevOps` |

Sign in to Azure DevOps as `buXX@attt21.onmicrosoft.com` (same account as `az login`).

Today is **Git only**. No Azure resource deploy. No pipelines.

Keep two folders straight:

| Folder | Role |
|--------|------|
| Course folder (GitHub clone) | Read notes/commands; copy starter Bicep from `day-04/samples/` |
| `iac-uXX` (Azure Repos clone) | Your working IaC repo — all commits and pushes go here |

---

## Lab 1 — Repository setup and collaboration

### Open the project

Browser: [https://dev.azure.com/org-bicep](https://dev.azure.com/org-bicep) → project **bicep-aug26**. Do not create a second project.

### Open or create your repo

Repos → open the repo list (repo name dropdown or **Manage repositories**).

**If `iac-uXX` is already there:** select it. Do not create a second repo for yourself.

**If `iac-uXX` is missing:** create an empty Git repo with that exact name:

1. Repos → **New repository** (or Project settings → Repositories → **New**).
2. Name: **`iac-uXX`** (your seat only — example `iac-u03`).
3. Type: **Git**.
4. Leave **Add a README** unchecked (empty repo — you will push Bicep next).
5. **Create**.

Do not create extra repos (`test`, `iac-demo`, someone else’s seat).

### Create a Personal Access Token (PAT) for clone/push

Azure Repos is private. HTTPS `git clone` / `git push` need a PAT (or Git Credential Manager browser sign-in as `buXX`).

1. Top-right avatar → **Personal access tokens** → **+ New Token**.
2. Name: `day4-iac` (any short name).
3. Organization: **All accessible organizations** (or `org-bicep`).
4. Expiration: today + a few days is enough for class.
5. Scopes: **Custom defined** → enable **Code** → **Read & write**.
6. **Create**. Copy the token once and keep it for the next step (password prompt).

### Clone your repo

```bash
cd ~
git clone https://dev.azure.com/org-bicep/bicep-aug26/_git/iac-uXX
cd iac-uXX
```

When Git asks for credentials:

- **Username:** `buXX@attt21.onmicrosoft.com`
- **Password:** paste the **PAT** (not your Azure AD password)

### Copy Bicep starter files into the repo root

Flat layout (files at the root of `iac-uXX`, not under `infra/`):

```bash
COURSE=/home/buXX/Azure-Bicep-with-Azure-DevOps
cp "$COURSE/day-04/samples/main.bicep" .
cp "$COURSE/day-04/samples/dev.bicepparam" .
```

On a laptop, set `COURSE` to wherever you cloned the GitHub course repo, then run the same two `cp` lines.

In both files, replace `XX` with your seat (example `u03` → owner `u03`, storage name `stb26u03`).

### Push existing Bicep code

An empty Azure Repos clone often starts on local branch `master`. Rename to `main` before the first push so later PRs match the handout:

```bash
git add main.bicep dev.bicepparam
git status
git commit -m "Add Bicep templates"
git branch -M main
git push -u origin main
```

Refresh Repos in the browser. `main.bicep` and `dev.bicepparam` should appear on `main`.

### Create feature branch and change a property

```bash
git checkout -b feature/access-tier
```

In `main.bicep`, change `accessTier` from `'Hot'` to `'Cool'`. Save.

```bash
git add main.bicep
git commit -m "Access tier Cool"
git push -u origin feature/access-tier
```

### Raise and complete Pull Request

In Azure DevOps: Repos → Pull requests → New pull request → source `feature/access-tier` → target `main` → Create.

Open the **Files** tab. Confirm only the `accessTier` line changed. **Complete** the pull request (merge).

Sync your machine:

```bash
git checkout main
git pull origin main
```

---

## Lab 2 — Branching workflow

Start from an up-to-date `main`:

```bash
git checkout main
git pull origin main
```

### Create two feature branches from the same commit

Create **both** branches **before** you merge either one:

```bash
git checkout -b feature/comment-a
git checkout main
git checkout -b feature/comment-b
```

### Simulate parallel code changes

On `feature/comment-a`, add this line at the **top** of `main.bicep`:

```bicep
// change-a
```

```bash
git checkout feature/comment-a
git add main.bicep
git commit -m "Comment A"
git push -u origin feature/comment-a
```

On `feature/comment-b`, add this line at the **same place** in `main.bicep`:

```bicep
// change-b
```

```bash
git checkout feature/comment-b
git add main.bicep
git commit -m "Comment B"
git push -u origin feature/comment-b
```

### Merge A (clean), then B (conflict)

1. Raise a PR: `feature/comment-a` → `main`. Complete it (no conflict).

2. Raise a PR: `feature/comment-b` → `main`. Azure DevOps shows a **conflict**.

3. Resolve on your machine:

```bash
git checkout feature/comment-b
git fetch origin
git merge origin/main
```

Git stops on `main.bicep`. Keep **one** of the two comment lines (or both on separate lines). Remove every conflict marker (`<<<<<<<`, `=======`, `>>>>>>>`).

```bash
az bicep build --file main.bicep
```

If that fails, open `main.bicep` and remove any markers you missed. Do **not** commit the generated `main.json`.

```bash
git add main.bicep
git commit -m "Resolve main.bicep conflict"
git push origin feature/comment-b
```

4. In Azure DevOps, refresh the PR and **Complete** it.

### Track commit history

```bash
git checkout main
git pull origin main
git log --oneline --decorate --graph -n 15
```
