from pathlib import Path

import polib
from bson import BSON

input_path = Path("target/videos/episodes")
output_path = Path("dist/videos/episodes")

print(f"Importing video subtitles from {input_path}...")

episode_names = [
    "ODCINEK 1: Monarch Solutions",
    "ODCINEK 2: Więzień",
    "ODCINEK 3: Oszustwo",
    "ODCINEK 4: Łódź Ratunkowa",
]

for caption_override_path in input_path.rglob("**/*_captions_override.po"):
    episode_id = int(caption_override_path.parent.name[1]) - 1

    po = polib.pofile(caption_override_path)
    output_data = {"episode_title": episode_names[episode_id]}
    segments = []

    last_text = None

    for entry in po:
        current_segment = int(entry.msgctxt.replace("s", ""))
        current_text = entry.msgstr if entry.msgstr else entry.msgid

        while current_segment != len(segments):
            segments.append(last_text)

        segments.append(current_text)

        last_text = current_text

    output_data["segments"] = segments
    output_path_final = Path(output_path) / caption_override_path.relative_to(
        input_path
    ).with_suffix(".bson")
    output_path_final.parent.mkdir(parents=True, exist_ok=True)

    print(f"Writing to {output_path_final}...")

    with open(output_path_final, "wb") as f:
        f.write(BSON.encode(output_data))
