# SWE-gen-Go

<p align="center">
  <a href="https://github.com/abundant-ai/SWE-gen-Go">
    <img src="assets/swegen-go-banner.jpg" style="height: 20" alt="SWE-gen Go banner" />
  </a>
</p>

> 1000 Go tasks generated from X open-source GitHub repos using [SWE-gen](https://github.com/abundant-ai/SWE-gen).

## Each task
- is a merged GitHub PR with 2-10 source files edited
- has Fail-to-Pass unit tests
- passes NOP (baseline fails) and Oracle (fix succeeds) validation

## Getting Started

Install [**Harbor**](https://github.com/laude-institute/harbor):

```shell
uv tool install harbor
```

Run with Codex:

```shell
export OPENAI_API_KEY=<YOUR-KEY> 
harbor run --dataset swe-gen-go \
   --agent codex \
   --model openai/gpt-5.2-codex \
   --n-concurrent 4
```

This command automatically downloads the tasks.

<p align="center">
  <img src="assets/pie_chart.jpg" style="height: 20em" alt="SWE-gen Go pie chart" />
</p>