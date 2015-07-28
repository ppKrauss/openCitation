# Open Coherence
Mini-framework for check openness-coherence of contents about liceses, extensions and citations.

This project, focusing on legal and scientific contents, offers tools and datasets for describe open contents with certainty of openness and tools for measure the degreee of openess.

## Introduction
Legal and scientific documents are typical [free contents](https://en.wikipedia.org/wiki/Free_content#Legislation), and in recent years they are stored in big digital repositoris that archives publicly accessible full-text documents in standard formats, as a form of *digital [legal deposit](https://en.wikipedia.org/wiki/Legal_deposit)*.

* Typical repositories of scientific literature (''sci-docs''): [SciELO](https://en.wikipedia.org/wiki/SciELO) and [PubMed Central](https://en.wikipedia.org/wiki/PubMed_Central). Access to contents in [XML JATS format](https://en.wikipedia.org/wiki/Journal_Article_Tag_Suite) and PDF.

* Typical repositories of legislation (''law-docs''): [BR (LexML)](http://www.lexml.gov.br/),  [EU countries (N-Lex)](http://eur-lex.europa.eu/n-lex/), [UK (legislation)](http://www.legislation.gov.uk/browse). Access to contents in HTML, PDF and other formats.

In both (sci-docs and law-docs) the content is published by an authority, like a [scientific journal](https://en.wikipedia.org/wiki/Scientific_journal) or a [government gazette](https://en.wikipedia.org/wiki/Government_gazette). Only official versions (of law-docs and sci-docs) possess legal probative value. The *official repositories* preserves the documents and its  probative value.

### Openness degree of a license
The characterization of the "openness" of a document (or a set of documents as collection or repository) can be formalized by the following procedure (simplifyed by the [licenses table](./data/licenses.csv)):

1. check license-type of the document;
2. check the most similar canonical-license-type (the CC-types illustred below);
3. use the `opennessDegree` as "openness numeric indicator".

![The opennes degree](./reports/imgs/openessDeg-CC-licenses-short.png "The opennes degree")

The *openness degree* is illustred here by the [CC licenses ordering](https://commons.wikimedia.org/wiki/File:Ordering_of_Creative_Commons_licenses_from_most_to_least_open.png), but it can be enhanced with more canonical licenses, taken from [OpenDefinition-conformant licenses](http://opendefinition.org/licenses/). 

### Coherence of law-doc collections
When a collection have an explicit license, like [UK](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/2/) or [GE](https://www.govdata.de/dl-de/by-2-0) official law-doc collections, it is easy to audit: check if the license is in fact respected, comparing the coherence between observed openness of each law-doc in the country's repository, and the country's license for that collection.

When there are no explicit license: we can interpret and build a "fake license" (**see [reports](./reports)**) to use in the same way.

### Coherence of sci-doc collections

When the repository obligates that each document express its license, as [PubMed Central](http://www.ncbi.nlm.nih.gov/pmc/about/copyright/), or offers a default-license, like [SciELO](http://blog.scielo.org/en/2014/08/29/scielo-participates-in-the-global-coalition-supporting-creative-commons-licenses-to-access-journal-articles/), it is easy to audit the coherence between observed openness of each sci-doc in the repository.

(scientific documents of open repositories not need interpreted "fake license").

### Extension coherence
Some documents need an "extension", like appendix, external figures, external maps, tables, lists, databases, etc. On science literature they are [supplementary matterial](http://jats.nlm.nih.gov/archiving/tag-library/1.0/n-q6p0.html) and *commom database*; in legislation they are [attachment](http://docs.oasis-open.org/legaldocml/akn-core/v1.0/csprd01/part2-specs/material/AkomaNtoso30-csd13_xsd_Element_attachment.html) (or appendix and other documental objects) that can't published in the same document's body, or that is reused by other law-docs. 

As extensions are explicit parts of the document, they are not subject to "relevance" interpretation, so, they **must use the same license** tham it's document.

### Citation coherence
&nbsp;<small>(see xxx)</small>
A complementar indicator of openness, [under discussion](https://github.com/okfn/opendefinition/wiki/Citation-alike-clauses-of-open-licenses-for-law#user-content-the-citation-alike-clause-and-observance), is checking the observance of the same or superior *openess degree* in a cited document (when [citing external sources](https://en.wikipedia.org/wiki/Wikipedia:Citing_sources)). When cited document have less *degree*,  we can say that the citation is not coherent.

[Scientific literature](https://en.wikipedia.org/wiki/Scientific_literature) use *bibliographic citation*, it is a fundation of the scientific research. By other hand,  legislators avoids, in law-docs, the citation of external documents: the usual is a law-doc citing another law-doc of the same legislative system, not "external" documents... Is usual for government and industry to reuse works, as recommendations and studies that, otherwise, would cost a lot of money. The reuse of documents reduce costs, so, this is the main motivation to the sporadic external citation in law-docs.

In both, sci-docs and law-docs,  external complementar material (appendix, table, map, etc.) can be considered "cited document". In sci-docs there are also a [standard reference-list](http://jats.nlm.nih.gov/archiving/tag-library/1.0/n-ajd0.html) pointing to external and independent documents.  In law-docs the [legal citation analysis](https://en.wikipedia.org/wiki/Legal_citation#Legal_citation_analysis)  determinates what documents are external to the legal system and are in fact a complement of the law.

In both, sci-docs and law-docs, may be difficult  cite only open documents... The "context of citation" may determine a *weighting* of relevance:

* in law-docs a citation that *blocks the undertstand of an obligation*, is really a problem; while a citation that is only a complementar explanation, or it not determinates an obligation, not blocks. 

* in sci-docs a citation that is the unique to check scientific merit of a central ideia of the article, is more important than other one that  offers (open) alternatives, or is about a secondary matter.

<!---
 ... When all cited documents are open,  **When it occurs, we can say that the document citations are *coherent* with its license**.
OLD DRAFT, lixo:
### Choice and observance of openness degree
Both writers, sci-doc author or legislator, can influency the choice of cited documents. If the "contract" between writer and authority not states any thing about citation, the writer can cite copyrighted documents. But the authorities, of legal system or sci-journal, they can (is possible to) obligate some kind of observance to preserve openness in citations, that is: a cited document must use same license or a license with more openness.
..fig...
The "openness degree" is illustred by the CC licenses ordering. A cited document can have most open license, or a license with the same degree. **When it occurs, we can say that the document citations are *coherent* with its license**.
-->
## Objective
The aim of this project is to offer a practical and theoretical *framework* (at least a proof of concept) to subsidise the characterization of "openness coherence" in repositories and collections, of scientific and legislative documents. Spliting into specific goals:

* Show the *official collections*: via [`lawDocsRepos` dataset](./data/lawDocsRepos.csv), each contry's official law-doc repository.

* Show the  *official licenses*: via [`licenses` dataset](./data/licenses.csv) list all known licenses used in official repositories, and via [`reports/inferredLicense` consensual interpretation](./reports), show the "inferred licenses" of countries that use no explicit license.

* *Coherence in official collections*: via [`lawDocsRepos` dataset](./data/lawDocsRepos.csv), describing official repositories, and [`lawDocs` dataset](./data/lawDocs.csv), sampling law-docs (as evidences), 

monitoring general cumpliance of the "expected licence" in all repository's documents. 
* *Extension coherence*: 
* *Citation coherence*: the aim is to offer tools and datasets for describe open contents with certainty of openness at cited documents, and tools for measure of percentage of cited materials that are open, in contexts without this certainty.

## Datasets 
[OKFN Dataset standards](https://github.com/datasets) was adopted in this project:
* folder `./data` with tabular `.csv` files;
* file `datapackage.json` with file description.

File description summary:

* `./data/licenses.csv` - field `abbrev` is a key (label based on name abbreviation) for each license used in this project. Other fields describes the license and it resouces.

* `./data/lawDocsRepos.csv` - Official digital repositories of law-documents of each sampled country. Some fields, as `legalSys`, can be checked [at Wikipedia's corresponding articles](https://en.wikipedia.org/wiki/List_of_national_legal_systems).

* `./data/lawDocs.csv` - Samples of law-documents taked from lawDocsRepos. Key, checked licenses and URLs.

* ... sci-docs ... repos and samples... 

All these files can be [friendly edit at this open folder of collaborative sheets](https://drive.google.com/folderview?id=0ByK4EZuhc93QfmY1NHFvS3lHbmtzQ2Frb2hOMVhfdzdDLVpmemc2VFY0TDJISWw0aFo3UU0&usp=sharing).

## Legislation license reports
Each contry that not have an explicit *official license* defined for its law-docs (at official legislation repositories), need a *"inferred license"*, that is described in this project as a uniform report.

Report summary:

* `./reports/inferredLicense-BR.csv` - Inferred licenses for Brazilian legislation and its law-documents.
* ... please navigate and check where you can collaborate ...

### Methodology
After `lawDocsRepos` and `lawDocs` sheets  are filled, and  demand on a *inferred license* confirmed:

1. Make a copy of `./reports/template.md` named `inferredLicense-XX.md` where `XX` is the country code (as *country* at `lawDocsRepos`);

2. Fill the `??1` placeholders with the corresponding `lawDocsRepos` fields.

3. Fill the rest of the report (use ex. `inferredLicense-BR.md` as reference model) to be publish it as a "DRAFT" and start a collaborative work at *git*.

4. Fill the section "Endorsed the conclusion" when draft can change the status, making the first change from "draft" to "revision".

5. Change the status from "revision" to "accepted" when there are at least 5 endorsements.

6. Change the version (ex. from 1.0 to 1.1) when make updates with only minor text revision.

7. Change the version (ex. from 1 to 2) when updates change something at "Conclusion" section.

## ...Planed tools...
...

## NOTES
* not be confuse with "open citation" of bibliographic references, https://opencitations.wordpress.com/
* ...
