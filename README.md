# openCitation
Mini-framework for check opennes of contents cited by open contents.

This project, focusing on legal and scientific contents, offers tools and datasets for describe open contents with certainty of openness at cited documents, and tools for measure of percentage of cited materials that are open, in contexts without this certainty.

## Introduction
Legal and scientific documents are typical [free contents](https://en.wikipedia.org/wiki/Free_content#Legislation), and in recent years they are stored in big digital repositoris that archives publicly accessible full-text documents in standard formats, as a form of *digital [legal deposit](https://en.wikipedia.org/wiki/Legal_deposit)*.

* Typical repositories of scientific literature (''sci-docs''): [SciELO](https://en.wikipedia.org/wiki/SciELO) and [PubMed Central](https://en.wikipedia.org/wiki/PubMed_Central). Access to contents in [XML JATS format](https://en.wikipedia.org/wiki/Journal_Article_Tag_Suite).

* Typical repositories of legislation (''law-docs''): [BR](http://www.lexml.gov.br/),  [EU countries](http://eur-lex.europa.eu/n-lex/), [UK](http://www.legislation.gov.uk/browse). Access to contents in HTML, PDF and other formats.

In both (sci-docs and law-docs) the content is published by an authority, like a [scientific journal](https://en.wikipedia.org/wiki/Scientific_journal) or a [government gazette](https://en.wikipedia.org/wiki/Government_gazette). The authority of a sci-doc with its author, they do the choice of the sic-doc's license. The  legal system (country's explicit or inferred "general law-doc license") with authority of a law-doc,  makes the choice of law-doc's license. The  legislator (the law-doc author) not make any choice about law-doc license.

Other versions (ex. draft, compiled or commented) or formats, like the printed version, may be not preserve openness, as its reader must pay per some added value to the official digital content. The license of this "other version" must not be confused with the license of the official digital version. Only official versions (of law-docs and sci-docs) possess legal probative value.

### Choice and observance of openness degree
Both writers, sci-doc author or lagislator, can influency the choice of cited documents. If the "contract" between writer and authority not states any thing about citation, the writer can cite copyrighted documents. But the authorities, of legal system or sci-journal, they can (is possible to) obligate some kind of observance to preserve openness in citations, that is: a cited document must use same license or a license with more openness.

The "openness degree" is illustred by the [CC licenses ordering](https://commons.wikimedia.org/wiki/File:Ordering_of_Creative_Commons_licenses_from_most_to_least_open.png). A cited document can have most open license, or a license with the same degree. **When it occurs, we can say that the document citations are *coherent* with its license**.

## Datasets 
[OKFN Dataset standards](https://github.com/datasets) was adopted in this project:
* folder `./data` with tabular `.csv` files;
* file `datapackage.json` with file description.

File description summary:

* `./data/licenses.csv` - field `abbrev` is a key (label based on name abbreviation) for each license used in this project. Other fields describes the license and it resouces.

* `./data/lawDocsRepos.csv` - Official digital repositories of law-documents of each sampled country.

* `./data/lawDocs.csv` - Samples of law-documents taked from lawDocsRepos. Key, checked licenses and URLs.

* ... sci-docs ... repos and samples... 

## Legislation license reports
Each contry that not have an explicit license defined for its law-docs and official legislation repositories, need a "inferred license", that is described in this project as a uniform report.

Report summary:

* `./reports/inferred-br.csv` - Inferred licenses for Brazilian legislation and its law-documents.
* ...

## ...Planed tools...
...

## NOTES
* not be confuse with "open citation" of bibliographic references, https://opencitations.wordpress.com/
* ...
