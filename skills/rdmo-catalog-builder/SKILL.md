---
name: rdmo-catalog-builder
description: Design, build, and publish RDMO catalogs via the REST API by creating option sets, attributes, questions, pages, sections, and catalogs following the RDMO catalog development guide.
---

# RDMO Catalog Builder

Use this skill whenever you need to create or evolve an RDMO catalog programmatically. It distills the official "Catalog development" guide and maps each step to the management API exposed by the RDMO instance referenced by `RDMO_URL`/`RDMO_TOKEN`.

## Setup

1. Ensure the credentials are available (typically in `~/.env`):
   ```bash
   export RDMO_URL=${RDMO_URL:?set RDMO_URL}
   export RDMO_TOKEN=${RDMO_TOKEN:?set RDMO_TOKEN}
   ```
2. Optional but recommended: install `jq` for inspecting JSON payloads.
3. Test connectivity before you start:
   ```bash
   curl -sf -H "Authorization: Token $RDMO_TOKEN" "$RDMO_URL/api/v1/questions/catalogs/" | jq 'length'
   ```
4. Keep the OpenAPI description handy: `~/RDMO API (v1).yaml`.

## Building blocks refresher

The management guide emphasises a flexible hierarchy. Confirm the structure on paper before touching the API:

Catalog → Sections → Pages → Questions and/or Question sets → Questions → Options (held in Option sets)

Important: pages do **not** need to contain question sets. A page may link directly to one or more questions, question sets, or both. Use question sets only when you want to group or nest questions for structure, reuse, or collections.

Each question must reference a unique Attribute. Reuse existing attributes when possible to keep catalogs portable.

Language rule: when creating or updating any catalog element with translatable fields, always provide both English and German values. That means:
- Catalogs, sections, pages, question sets, and questions should include the EN/DE title/help fields they support.
- Use EN/DE pairs consistently for `title`, `short_title`, `verbose_name`, `help`, and question text fields.
- Do not leave newly created structural elements with only one language filled in.

## Workflow

### 1. Inventory existing resources

Retrieve what is already in the instance so you can reuse IDs:

```bash
curl -s -H "Authorization: Token $RDMO_TOKEN" \
  "$RDMO_URL/api/v1/options/optionsets/?uri_prefix=<prefix>" | jq
curl -s -H "Authorization: Token $RDMO_TOKEN" \
  "$RDMO_URL/api/v1/domain/attributes/?uri_prefix=<prefix>" | jq '.[].uri'
```

Substitute `<prefix>` with your institutional namespace (for the sandbox this is usually `https://rdmorganiser.github.io/terms`).

### 2. Create, extend, and use option sets

Before writing a question, decide whether the answer should be free text or whether it should come from a fixed set of choices.

Use an option set when the question is:
- specific in tone
- best answered by a predefined list
- a single-choice or multiple-choice question
- likely to benefit from controlled vocabulary / consistent answers

For very open questions, do **not** invent an option set unless the user explicitly wants one.

If you are unsure, suggest an option set and ask the user whether they want one.

#### Create option values

Create options first. Minimum payload:
```bash
cat <<'JSON' > option.json
{
  "uri_prefix": "https://example.org/terms",
  "uri_path": "options/example_dna_method",
  "comment": "Methods for omics experiments",
  "text_en": "DNA methylation assay",
  "text_de": "DNA-Methylierungsassay",
  "help_en": "Describe the technique used.",
  "help_de": "Beschreiben Sie die verwendete Technik.",
  "additional_input": ""
}
JSON

curl -sX POST -H "Authorization: Token $RDMO_TOKEN" \
  -H "Content-Type: application/json" \
  -d @option.json "$RDMO_URL/api/v1/options/options/"
```

#### Create or update an option set

Attach options in the desired order. The `options` array stores `option` + `order` pairs.

```bash
cat <<'JSON' > optionset.json
{
  "uri_prefix": "https://example.org/terms",
  "uri_path": "optionsets/omics_methods",
  "comment": "Experimental technique choices for omics projects",
  "order": 10,
  "title_en": "Experimental techniques",
  "title_de": "Experimentelle Techniken",
  "options": [
    {"option": <OPTION_ID>, "order": 10}
  ]
}
JSON

curl -sX POST -H "Authorization: Token $RDMO_TOKEN" \
  -H "Content-Type: application/json" \
  -d @optionset.json "$RDMO_URL/api/v1/options/optionsets/"
```

To add more options to an existing option set, PATCH the set and include the full updated `options` array (again using `option` + `order` objects). Keep the order values spaced out so you can insert new options later.

#### Assign an option set to a question

When a question should use a predefined set of answers, include the option set ID in the question payload:

```json
{
  "optionsets": [<OPTIONSET_ID>]
}
```

For checkbox, radio, select, autocomplete, and free-autocomplete style questions, the option set is usually essential. For open-text questions, leave `optionsets` empty unless there is a strong reason to guide the answer.

### 3. Create and use conditions

Conditions control whether parts of a catalog are shown or hidden based on answers given earlier. They are useful for:
- showing follow-up questions only when relevant
- skipping irrelevant sections/pages/questions
- enabling tasks based on user answers
- building decision logic around yes/no or option-based questions

A condition always evaluates the **attribute of the source question**, not the question record itself. In other words:
- `source` = the attribute ID attached to the question that provides the answer
- `target_text` = a literal text value to compare against
- `target_option` = an option ID from the source question's option set

A condition evaluates the source attribute against a target value using a relation such as `eq`, `neq`, `contains`, `gt`, `gte`, `lt`, `lte`, `empty`, or `notempty`.

Typical use cases:
- If the user answers "yes" to a sensitive-data question, show additional questions.
- If a specific option is selected, show follow-up pages or tasks.
- If a text field contains a keyword or if a numeric threshold is crossed, branch the catalog accordingly.

#### Create a condition

Minimum payload:
```bash
cat <<'JSON' > condition.json
{
  "uri_prefix": "https://example.org/terms",
  "uri_path": "conditions/project/has_sensitive_data",
  "comment": "Show additional questions when sensitive data is present.",
  "source": <ATTRIBUTE_ID>,
  "relation": "eq",
  "target_text": "1"
}
JSON

curl -sX POST -H "Authorization: Token $RDMO_TOKEN" \
  -H "Content-Type: application/json" \
  -d @condition.json "$RDMO_URL/api/v1/conditions/conditions/"
```

For option-based conditions, use `target_option` instead of `target_text` and point `source` to the attribute of the source question:
```json
{
  "source": <ATTRIBUTE_ID>,
  "relation": "eq",
  "target_option": <OPTION_ID>
}
```

Example: if question 144 uses attribute 189 (`file_formats`) and option 189 is `CSV`, the condition should be written as:
```json
{
  "source": 189,
  "relation": "eq",
  "target_option": 189
}
```
This correctly checks whether "Which file formats are planned?" includes CSV.

Common pitfalls:
- Do **not** use the question ID as `source`; conditions work on the question's attribute ID.
- Do **not** put an option ID in `source`; the option belongs in `target_option`.
- Do **not** use `target_text` for checkbox/radio/select answers unless the answer is actually free text.

#### Attach a condition to a catalog element

Conditions can be linked to pages, question sets, questions, or tasks by including the condition ID in the relevant array:

```json
{
  "conditions": [<CONDITION_ID>]
}
```

Multiple conditions are combined with logical OR on the element they are attached to, so the element is shown if any linked condition matches.

### 4. Reuse or create attributes

Prefer existing attributes from the RDMO domain at:
`https://raw.githubusercontent.com/rdmorganiser/rdmo-catalog/refs/heads/main/rdmorganiser/domain/attributes.xml`

This is the primary source of truth. Avoid creating new attributes unless there is no suitable existing match.

### How to find a suitable attribute

1. **Search by meaning, not by label**. Start with the information you want to capture, then look for a matching path or key in the XML.
2. **Inspect the hierarchy**. Attributes are arranged as a tree. The `parent` chain shows whether you need a broad attribute (for a page/question set) or a leaf attribute (for a specific question).
3. **Check the XML fields**:
   - `dc:uri` or `uri` = full attribute URI
   - `uri_prefix` = base namespace
   - `key` = leaf name used in the tree
   - `path` = full hierarchical path (for example `project/dataset/description`)
   - `dc:comment` = human explanation, when present
   - `parent` = the next broader attribute
4. **Prefer the closest existing semantic match**. Reuse an attribute if it captures the same concept even if the wording differs.
5. **If several attributes look plausible, show the shortlist to the user and let them decide.** Do not pick a potentially wrong attribute silently.
6. **Only create a new attribute when no good fit exists.** New attributes are the last resort because they reduce catalog portability and may need to be shared with the RDMO community.

Useful lookup pattern:
```bash
curl -s https://raw.githubusercontent.com/rdmorganiser/rdmo-catalog/refs/heads/main/rdmorganiser/domain/attributes.xml \
  | rg -n "<path>|<key>|dc:comment|dc:uri|<parent"
```

If you need a deeper inspection, filter for a specific keyword:
```bash
curl -s https://raw.githubusercontent.com/rdmorganiser/rdmo-catalog/refs/heads/main/rdmorganiser/domain/attributes.xml \
  | rg -n "dataset/description|project_start|preservation/responsible_person"
```

When you must add a discipline-specific attribute:

```bash
cat <<'JSON' > attribute.json
{
  "uri_prefix": "https://example.org/terms",
  "uri_path": "domain/project/omics/method",
  "key": "project_omics_method",
  "comment": "Primary technique used in the omics workflow",
  "parent": <PARENT_ATTRIBUTE_ID>
}
JSON

curl -sX POST -H "Authorization: Token $RDMO_TOKEN" \
  -H "Content-Type: application/json" \
  -d @attribute.json "$RDMO_URL/api/v1/domain/attributes/"
```

If no existing attribute fits after reviewing the XML, ask the user whether you should create a new attribute before doing so.

Follow the guide’s warning: new attributes reduce catalog portability. Coordinate with the RDMO community when in doubt.

### 5. Craft questions

Each question needs:
- `uri_prefix`, `uri_path`
- An `attribute` ID (the one created or reused)
- `widget_type` (e.g. `select`, `text`, `yesno`)
- `value_type` (often `option` for select/checkbox, `text` otherwise)
- Localised text fields in both languages (`text_en`, `text_de`, `help_en`, `help_de`, `verbose_name_en`, `verbose_name_de`)
- Optional links to `optionsets`

When choosing the widget, start with the most probable/default widget for the answer type:
- Descriptive/free-form answer → `textarea`
- Short free text → `text`
- Binary decision → `yesno`
- Single choice from predefined answers → `radio` or `select`
- Multiple choice from predefined answers → `checkbox`
- Free choice with suggestions → `select_creatable`
- Date → `date`
- Numeric range → `range`
- File upload → `file`

If the question sounds open-ended, prefer free text widgets and usually do **not** create an optionset.
If the question sounds specific, enumerative, or decision-based, consider an optionset first.
If it is unclear whether an optionset is needed, suggest one and ask the user before creating the question.

When a question uses an option set, include the option set ID in `optionsets`.

If a question could reasonably fit more than one widget, prefer the one that best matches the expected user input and the DFG/RDMO source wording.

Use `is_collection: true` when the answer should be repeatable as a list of answers. This is common for checkbox questions, and it can also be used on question sets or pages when the same group of questions should be answered multiple times for different items.

For every newly created question, always fill both EN and DE fields, even if the German text is only a first draft.

Example:
```bash
cat <<'JSON' > question.json
{
  "uri_prefix": "https://example.org/terms",
  "uri_path": "questions/project/omics/method",
  "comment": "Primary method question",
  "attribute": <ATTRIBUTE_ID>,
  "is_optional": false,
  "widget_type": "select",
  "value_type": "option",
  "optionsets": [<OPTIONSET_ID>],
  "text_en": "Which experimental technique will you apply?",
  "text_de": "Welche experimentelle Technik wenden Sie an?",
  "help_en": "Select the method used to generate the dataset.",
  "help_de": "Wählen Sie die Methode aus, mit der der Datensatz erzeugt wird.",
  "verbose_name_en": "Experimental technique",
  "verbose_name_de": "Experimentelle Technik"
}
JSON

curl -sX POST -H "Authorization: Token $RDMO_TOKEN" \
  -H "Content-Type: application/json" \
  -d @question.json "$RDMO_URL/api/v1/questions/questions/"
```

### 6. Add questions directly to pages or group them in question sets

Use question sets when you want to structure related questions or nest them. They are optional.

If you do use a question set, supply `questions` with `question` + `order` objects:

Always provide both language variants for the question set metadata (`title_en`/`title_de`, `help_en`/`help_de`, `verbose_name_en`/`verbose_name_de`).

```bash
cat <<'JSON' > questionset.json
{
  "uri_prefix": "https://example.org/terms",
  "uri_path": "questionsets/project/omics/setup",
  "comment": "Omics setup block",
  "attribute": <PARENT_ATTRIBUTE_ID>,
  "is_collection": false,
  "title_en": "Omics setup",
  "title_de": "Omics-Einrichtung",
  "help_en": "",
  "help_de": "",
  "verbose_name_en": "Omics setup",
  "verbose_name_de": "Omics-Einrichtung",
  "questions": [
    {"question": <QUESTION_ID>, "order": 10}
  ]
}
JSON

curl -sX POST -H "Authorization: Token $RDMO_TOKEN" \
  -H "Content-Type: application/json" \
  -d @questionset.json "$RDMO_URL/api/v1/questions/questionsets/"
```

You can also place questions directly on a page without any question set in between. If the page itself should repeat for multiple items, set `is_collection: true` on the page.

### 7. Assemble pages

Pages can contain standalone questions, question sets, or both. Use whichever structure fits the catalog best.

Direct question example:

Always provide both language variants for page metadata (`title_en`/`title_de`, `short_title_en`/`short_title_de`, `help_en`/`help_de`, `verbose_name_en`/`verbose_name_de`).

```bash
cat <<'JSON' > page.json
{
  "uri_prefix": "https://example.org/terms",
  "uri_path": "pages/project/omics",
  "comment": "Page for omics configuration",
  "attribute": <PARENT_ATTRIBUTE_ID>,
  "is_collection": false,
  "title_en": "Omics configuration",
  "title_de": "Omics-Konfiguration",
  "short_title_en": "Omics",
  "short_title_de": "Omics",
  "help_en": "",
  "help_de": "",
  "verbose_name_en": "Omics configuration",
  "verbose_name_de": "Omics-Konfiguration",
  "questions": [
    {"question": <QUESTION_ID>, "order": 10}
  ]
}
JSON

curl -sX POST -H "Authorization: Token $RDMO_TOKEN" \
  -H "Content-Type: application/json" \
  -d @page.json "$RDMO_URL/api/v1/questions/pages/"
```

If you prefer grouping, attach question sets via the `questionsets` array as well.

### 8. Create sections

Sections group pages into larger themes. Provide `pages` array with IDs and orders.

Always provide both language variants for section metadata (`title_en`/`title_de`, `short_title_en`/`short_title_de`).

```bash
cat <<'JSON' > section.json
{
  "uri_prefix": "https://example.org/terms",
  "uri_path": "sections/project/experiment",
  "comment": "Experimental setup section",
  "order": 20,
  "title_en": "Experimental setup",
  "short_title_en": "Setup",
  "pages": [
    {"page": <PAGE_ID>, "order": 10}
  ]
}
JSON

curl -sX POST -H "Authorization: Token $RDMO_TOKEN" \
  -H "Content-Type: application/json" \
  -d @section.json "$RDMO_URL/api/v1/questions/sections/"
```

### 9. Publish the catalog

Finally create the catalog and attach sections.

Always provide both language variants for the catalog title and help text (`title_en`/`title_de`, `help_en`/`help_de`).

Example:

```bash
cat <<'JSON' > catalog.json
{
  "uri_prefix": "https://example.org/terms",
  "uri_path": "catalogs/omics",
  "comment": "Catalog for omics projects",
  "order": 50,
  "available": true,
  "title_en": "Omics project planning",
  "sections": [
    {"section": <SECTION_ID>, "order": 10}
  ]
}
JSON

curl -sX POST -H "Authorization: Token $RDMO_TOKEN" \
  -H "Content-Type: application/json" \
  -d @catalog.json "$RDMO_URL/api/v1/questions/catalogs/"
```

Lock resources once they are stable (`"locked": true`) to prevent accidental edits, mirroring the guide’s recommendation.

### 10. Validate and export

Use the nested endpoint to inspect the assembled hierarchy and ensure ordering is correct:
```bash
curl -s -H "Authorization: Token $RDMO_TOKEN" \
  "$RDMO_URL/api/v1/questions/catalogs/<CATALOG_ID>/nested/" | jq
```

Export XML for sharing or backup:
```bash
curl -s -H "Authorization: Token $RDMO_TOKEN" \
  "$RDMO_URL/api/v1/questions/catalogs/<CATALOG_ID>/export/?format=xml" \
  -o catalog.xml
```

### 11. (Optional) Attach to projects or tasks

- Allow projects to use the catalog by keeping `available = true`.
- Assign tasks or conditions with the relevant endpoints (`/api/v1/tasks/tasks/`, `/api/v1/conditions/conditions/`) after the catalog skeleton is complete.

## Tips & guardrails

- Orders are free-form integers; use gaps (10, 20, …) so you can insert later items without renumbering.
- Keep URI paths and prefixes stable—changing them breaks references.
- Use `is_collection: true` whenever the answer should be a list or the same group of questions should repeat for multiple items. This applies to checkbox questions and can also be used on question sets or pages.
- Do not duplicate questions just to model repetition; prefer collection handling instead.
- Reuse option sets and attributes across catalogs to keep data interoperable, exactly as the guide advises.
- For every new section, page, question set, question, and catalog, verify that both EN and DE fields are present before posting.
- Toggle `locked` only after verifying via the nested view; unlocking requires admin privileges in some setups.

## Reference

The official narrative guide this skill codifies: [Catalog development](https://rdmo.readthedocs.io/en/latest/management/catalog-development.html). Consult it for editorial advice, naming conventions, and examples before automating steps.
