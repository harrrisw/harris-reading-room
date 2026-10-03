# Harris Reading Room: detailed guide

Run all commands below from the project root.

A personal Bash book manager built for Problem Set #2. Browse and search a persistent library, track reading status and ratings, and discover your next book through three parallel recommendation strategies.

## Run

Requires Bash 4+, standard Unix tools (`awk`, `sort`, `mktemp`, etc.), and [Gum](https://github.com/charmbracelet/gum#installation). No API key, Python, Node, or paid service is needed. The application works offline after installation.

**Windows:** Use Git for Windows' Bash in PowerShell or Windows Terminal. Install Gum locally from PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install-gum.ps1
```

The installer downloads Gum 2.0.2 for Windows x86-64 from the official release and verifies its published SHA-256 checksum. It writes only to `.bin/`. Then double-click `run.cmd`, or run this from PowerShell in the project folder:

```powershell
.\run.cmd
```

If the standalone Git Bash window shows only the title and tagline, press Ctrl+C and use `run.cmd` from File Explorer or PowerShell instead. That window uses MinTTY, whose interaction with native Windows console applications can prevent Gum's menu from appearing. The launcher uses the same Bash application and the same saved library. See [MinTTY's compatibility notes](https://mintty.github.io/).

**macOS/Linux:** install Gum using its official instructions (for example, `brew install gum`). macOS also needs a newer Bash (`brew install bash`); ensure `bash --version` reports 4 or later. Then run `bash app.sh`.

Use arrow keys and Enter to select menu items. `Back` returns from book selection; Ctrl+C cancels a prompt. A fresh clone creates an empty local library; personal `data/books.csv` records are excluded from Git. Try adding **Dune** by **Frank Herbert**, marking it finished, and giving it a rating before requesting recommendations.

## Architecture

`app.sh` only launches the UI. `ui/` owns Gum menus, input, and display; `workflows/` coordinates library and recommendation operations; `books/` enriches and searches books; `recommendations/` contains independent candidate generators and a stdin-to-stdout refiner. Only `data/book_database.sh` and its private `csv.awk` codec access `data/books.csv`. Components exchange headerless tab-separated records through stdout, while progress and errors go to stderr. `lib/common.sh` holds shared paths and validation. The layout follows **UI → Workflows → Components → Data → Storage**.

## Personalization

Harris Reading Room has a rainbow-colored title and focuses on history, fantasy, and science fiction. Change `config/interests.txt` to adjust these topics, one per line. History recommendations favor familiar authors: each weighted author match adds 15 points, compared with 3 for a genre match. Finished and highly rated books carry more weight, while ratings below 3 are ignored. Interest recommendations match catalog genres and tags; discovery selects unfamiliar genres outside your interests. The refiner reserves one shortlist slot for discovery. Suggestions explain when a familiar author influenced the recommendation. Set `NO_COLOR=1` to disable the rainbow title.

## Terminal commands

These commands work without Gum, making each layer easy to inspect:

```bash
bash workflows/manage_library.sh add 'Dune' 'Frank Herbert' reading
bash workflows/manage_library.sh list
bash workflows/manage_library.sh status 'Dune' 'Frank Herbert' finished
bash workflows/manage_library.sh rating 'Dune' 'Frank Herbert' 5
echo 'science fiction' | bash books/search_books.sh
bash workflows/get_recommendations.sh 6
```

Statuses: `owned`, `want-to-read`, `reading`, `finished`. Ratings: `0` (unrated) to `5`. The UI can save any recommendation to your want-to-read shelf.

The recommendation workflow launches all three Bash programs with `&`, stores each `$!`, reports `running` and `done`, and synchronizes using `wait`. It then pipes their combined output into `refine_recommendations.sh`. A failed worker makes the entire workflow fail instead of presenting a partial shortlist. You can also compose components yourself:

```bash
{ bash recommendations/recommend_from_history.sh
  bash recommendations/recommend_from_interests.sh
  bash recommendations/recommend_for_discovery.sh
} | bash recommendations/refine_recommendations.sh 5
```

## Data and interfaces

| Interface | Fields (tab-separated, no header) |
| --- | --- |
| Library list/search | title, author, genre, status, rating, link, year |
| Metadata lookup | title, author, genre, year, link |
| Recommendation candidate/final result | title, author, genre, year, link, score, reason |

`books/catalog.tsv` contains 26 curated books, with publication years and reference links. The expanded selection includes The Guns of August, The Proud Tower, The Fellowship of the Ring, The Two Towers, Dune Messiah, and Children of Dune. Metadata enrichment matches title and author case-insensitively. Unknown books are still saved with `Uncategorized`, an `unknown` year, and `-` for the reference; metadata is never invented. Add catalog rows to expand coverage. Recommendations are deterministic local rules over this finite catalog, not live internet or AI results.

CSV storage quotes all fields and escapes embedded quotation marks. Tabs, newlines, and control characters in book fields are rejected so records remain safe for pipelines. Duplicate identity is the case-insensitive title/author pair. Writers use a directory lock and atomic replacement; a lock timeout reports an error. If a machine crash leaves `data/books.csv.lock`, remove that empty directory only after confirming no app process is writing.

Set `BOOK_DB` to an alternative CSV path and `BOOK_INTERESTS_FILE` to an alternative interest file to keep multiple profiles. The app accepts single-line records it creates; it is not a general importer for arbitrary multiline CSV.

## Verification

```bash
bash tests/smoke.sh
```

Tests use temporary storage and cover persistence, CSV quoting, metadata, piped search, validation, duplicates, status/rating updates, recommendation ranking and exclusion, worker failures, concurrent writes, arbitrary working directories, and Bash syntax. Your real library is not modified.

## Demo and submission

Watch the [narrated terminal demo](../demo/harris-reading-room.mp4), or read its [notes and narration outline](../DEMO.md). It uses Harris's recorded narration and a temporary library, and demonstrates adding a book, updating status and rating, and getting recommendations.

The repository includes the application and narrated demo video. Enter its GitHub URL in the assignment sheet to submit it; the class-sheet submission is a separate step. `.bin/`, `.tools/`, and personal `data/books.csv` records are ignored; the Gum installer reproduces the Windows setup.
