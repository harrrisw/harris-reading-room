# Harris Reading Room

A personal terminal book manager for tracking books, ratings, and what to read next.

## How to run

Requires **Bash 4+**, standard Unix tools, and **[Gum](https://github.com/charmbracelet/gum#installation)**.

**Windows:** Install Git for Windows, open PowerShell in this project folder, and run:

```powershell
# First-time setup only:
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/install-gum.ps1
# Start the application:
.\run.cmd
```

Use PowerShell or Windows Terminal; the standalone Git Bash window may not display Gum menus. You can also double-click `run.cmd`.

**macOS/Linux:** Install Bash 4+ and Gum, then run `bash app.sh`. Use arrow keys to navigate and Enter to select. A rating of 0 means unrated.

Your personal library is stored locally in `data/books.csv` and excluded from Git. A fresh clone creates an empty library automatically.

## Architecture

The application follows **UI -> Workflows -> Components -> Data -> Storage**, using small Bash programs. `app.sh` starts the Gum menus in `ui/`; `workflows/` coordinates book operations; `books/` handles metadata and search; and `recommendations/` generates and refines suggestions. Only the data layer accesses `data/books.csv`. The recommendation workflow starts three independent programs in parallel, shows progress, waits for them to finish, and pipes their combined output into a refiner that removes duplicates and saved books before ranking the shortlist.

## Personalization

I personalized the app as **Harris Reading Room**, with a rainbow-colored title and interests in **history, fantasy, and science fiction**. I expanded the catalog and want-to-read shelf with books by Barbara W. Tuchman, J. R. R. Tolkien, and Frank Herbert. Recommendations favor familiar authors: each weighted author match adds 15 points versus 3 for a genre match, with extra weight for finished and highly rated books. A discovery slot keeps one suggestion outside my usual reading patterns. My interests are editable in `config/interests.txt`.

## Narrated demo

**[Watch the narrated demo (2 minutes 8 seconds)](demo/harris-reading-room.mp4)**

Shows the actual terminal app adding a book, updating its status and rating, and generating personalized recommendations. Narrated by Harris using his own recording. See the [demo notes and narration outline](DEMO.md).

More details: [commands, data formats, and troubleshooting](docs/GUIDE.md). Run integration checks with `bash tests/smoke.sh` in Bash.
