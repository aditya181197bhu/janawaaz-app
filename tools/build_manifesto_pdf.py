"""Builds assets/manifesto/manifesto_en.pdf and manifesto_hi.pdf from manifesto.json.

Uses headless Google Chrome to print HTML to PDF, because Chrome shapes Devanagari
correctly. Run from the janawaaz_app folder:  python3 tools/build_manifesto_pdf.py
"""
import html
import json
import pathlib
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
SRC = ROOT / "assets/manifesto/manifesto.json"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

PAGE = """<!doctype html><html lang="{lang}"><head><meta charset="utf-8"><style>
@page {{ size: A4; margin: 18mm 16mm; }}
body {{ font-family: {font}; color: #1A2138; font-size: 12.5pt; line-height: 1.55; }}
.band {{ background: linear-gradient(120deg, #14215A, #3D63C9); color: #fff; border-radius: 14px;
         padding: 22px 26px; margin-bottom: 18px; }}
.band h1 {{ margin: 0 0 4px; font-size: 26pt; }}
.band p {{ margin: 0; opacity: .85; }}
.draft {{ display: inline-block; background: #D9772B; color: #fff; border-radius: 10px; padding: 2px 10px;
          font-size: 9pt; margin-bottom: 8px; letter-spacing: .5px; }}
.intro {{ color: #5C6680; margin: 0 0 14px; }}
.section {{ break-inside: avoid; border: 1px solid #DDE3EF; border-radius: 12px; padding: 12px 18px; margin-bottom: 12px; }}
.section h2 {{ margin: 0 0 6px; font-size: 14.5pt; color: #1F3B8C; }}
.section ol {{ margin: 0; padding-left: 20px; }}
.foot {{ margin-top: 16px; font-size: 9.5pt; color: #5C6680; text-align: center; }}
</style></head><body>
<div class="band"><div class="draft">{draft}</div><h1>{title}</h1><p>{subtitle}</p></div>
<p class="intro">{intro}</p>
{sections}
<p class="foot">{foot}</p>
</body></html>"""


def build(data, lang):
    hi = lang == "hi"
    pick = lambda key: data[key + ("Hi" if hi else "En")]
    sections = "".join(
        "<div class='section'><h2>{}</h2><ol>{}</ol></div>".format(
            html.escape(s["titleHi" if hi else "titleEn"]),
            "".join(f"<li>{html.escape(p)}</li>" for p in s["pointsHi" if hi else "pointsEn"]),
        )
        for s in data["sections"]
    )
    return PAGE.format(
        lang=lang,
        font="'Kohinoor Devanagari', 'Devanagari Sangam MN', sans-serif" if hi else "'Helvetica Neue', Arial, sans-serif",
        draft="प्रारूप" if hi else "DRAFT",
        title=html.escape(pick("title")),
        subtitle=html.escape(pick("subtitle")),
        intro=html.escape(pick("intro")),
        sections=sections,
        foot="जन आवाज़ · मिर्ज़ापुर" if hi else "Jan Awaaz · Mirzapur",
    )


def main():
    data = json.loads(SRC.read_text(encoding="utf-8"))
    for lang in ("en", "hi"):
        with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False, encoding="utf-8") as f:
            f.write(build(data, lang))
        out = ROOT / f"assets/manifesto/manifesto_{lang}.pdf"
        subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
                        f"--print-to-pdf={out}", f"file://{f.name}"], check=True, capture_output=True)
        print("wrote", out.relative_to(ROOT), out.stat().st_size, "bytes")


if __name__ == "__main__":
    main()
