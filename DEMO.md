# Harris Reading Room demo

**[Watch the narrated demo (about 2 minutes)](demo/harris-reading-room.mp4)**

The video captures the real Bash/Gum app in a Windows pseudoterminal, with its terminal output rendered into a readable 1600 x 1000 video. It uses a temporary library rather than your personal reading records. The final recommendation screen is held while the narration concludes.

Narration is synthetic (Microsoft Zira), created at your request. It is not a recording of your own voice. The MP4 includes H.264 video and AAC audio and is stored directly in this project.

## Operations demonstrated

1. Add **Dune** by **Frank Herbert** with a reading status.
2. Browse its details, mark it finished, and rate it 5/5.
3. Generate recommendations using the three parallel strategies and inspect a familiar-author suggestion, **Children of Dune**.

The final screen offers to save the suggestion; the video does not demonstrate completing that save.

## Narration transcript

### 0:04 - Introduction

Welcome to Harris Reading Room, a personal book manager made from small Bash programs. The rainbow title and the interests in history, fantasy, and science fiction personalize the experience. This demonstration uses a temporary library and synthetic narration.

### 0:22 - Add a book

First, I select Add Book and enter Dune by Frank Herbert, with a status of reading. The interface collects the input, a workflow looks up metadata in the local catalog, and the data layer saves the book to C S V. No internet connection is needed.

### 0:42 - Update status and rating

Next, I browse the library and open Dune. Its details include the genre, publication year, reading status, and rating. I mark it finished and give it five stars. A rating of zero means unrated. Finished and highly rated books have more influence on future recommendations.

### 1:04 - Parallel recommendations

Now I request recommendations. Three Bash programs start in parallel: history, interests, and discovery. Their progress appears in the terminal. The workflow waits for all three, then pipes the combined candidates into a refiner. It removes duplicates and books already saved, ranks the results, and keeps a discovery option.

### 1:29 - Familiar-author explanation

This suggestion is by Frank Herbert, a familiar author. Author matches receive five times the weight of genre matches. The screen explains the recommendation and offers to save it to the want to read shelf. This demo showed adding a book, updating its reading record, and finding a personalized recommendation.

## Submission

Include `demo/harris-reading-room.mp4` when you push the project to GitHub. The README links to it directly. If GitHub does not play it inline, use the download/raw option to open the MP4 in a video player.
