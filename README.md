# code-docstring-corpus

This repository contains preprocessed Python functions and docstrings for automated code documentation (code2doc) and automated code generation (doc2code) tasks.

Paper: https://arxiv.org/abs/1707.02275

##### Update
The code-docstring-corpus version 2, with class declarations, class methods, module docstrings and commit SHAs is now available in the directory V2

#### Installation
The dependencies can be installed using `pip`:
```
pip install -r requirements.txt
```

Extraction scripts require AST Unparser ( https://github.com/simonpercivall/astunparse ), NMT tokenization requires the Moses tokenizer scripts ( https://github.com/moses-smt/mosesdecoder )

### Details

We release a parallel corpus of 150370 triples of function declarations, function docstrings and function bodies. We include multiple corpus splits, and an additional "monolingual" code-only corpus with corresponding synthetically generated docstrings.

The corpora were assembled by scraping from open source GitHub repository with the GitHub scraper used by Bhoopchand et al. (2016) "Learning Python Code Suggestion with a Sparse Pointer Network" (paper: https://arxiv.org/abs/1611.08307 - code: https://github.com/uclmr/pycodesuggest ) .

The Python code was then preprocessed to normalize the syntax, extract top-level functions, remove comments and semantically irrelevant whitespaces, and separate declarations, docstrings (if present) and bodies. We did not extract classes and their methods.

| directory | description |
|---        |---          |
| parallel-corpus | Main parallel corpus with a canonical split in  109108 training triples, 2000 validation triples and 2000 test triples. Each triple is annotated by metadata (repository owner, repository name, source file and line number). Also two versions of the above corpus reassembled into pairs: (declaration+body, docstring) and (declaration+docstring, body), for  code documentation tasks and code generation tasks, respectively. You may refer to [the Readme in this folder](./parallel-corpus/) for descriptions about escape tokens| 
| code-only-corpus | A code-only corpus of 161630 pairs of function declarations and function bodies, annotated with metadata. |
| backtranslations-corpus | A corpus of docstrings automatically generated from the code-only corpus using Neural Machine Translation, to enable data augmentation by "backtranslation" |
| nmt-outputs | Test and validation outputs of the baseline Neural Machine Translation models. |
| repo_split.parallel-corpus | An alternate train/validation/test split of the parallel corpus which is "repository-consistent": no repository is split between training, validation or test sets. |
| repo_split.code-only-corpus | A "repository-consistent" filtered version of the code-only corpus: it only contains fragments which appear in the training set of the above repository. |
| scripts | Preprocessing scripts used to generate the corpora. |
| V2 | code-docstring-corpus version 2, with class declarations, class methods, module docstrings and commit SHAs. |


### Baseline results

In order to compute baseline results, the data from the canonical split (parallel-corpus directory) was further sub-tokenized using Sennrich et al. (2016) "Byte Pair Encoding" (paper: https://arxiv.org/abs/1508.07909 - code: https://github.com/rsennrich/subword-nmt ). Finally, we trained baseline Neural Machine Translation models for both the code2doc and the doc2code tasks using Nematus (Sennrich et al. 2017, paper: https://arxiv.org/abs/1703.04357 - code: https://github.com/rsennrich/nematus ).

Baseline outputs are available in the nmt-outputs directory.

We also used the code2doc model to generate the docstring corpus from the code-only corpus which is available in the backtranslations-corpus directory.

| Model 	             | Validation BLEU | Test BLEU |
|--- 	                     |---   	       |---        |
| declbodies2desc.baseline   | 14.03           | 13.84     |
| decldesc2bodies.baseline   | 10.32           | 10.24     |
| decldesc2bodies.backtransl | 10.85           | 10.90     |

Bleu scores are computed using Moses multi-bleu.perl script

## Tutorial
The following Tutorial shows you how to:
1. install
2. preprocess the parallel corpus
3. train a model

### 1. Install Nematus and scripts for preprocessing:
**mosesdecoder** (just for preprocessing, no installation required)  
`git clone https://github.com/moses-smt/mosesdecoder`  
**subword-nmt** (for BPE segmentation)  
`git clone https://github.com/rsennrich/subword-nmt`  
**Nematus**  
`git clone https://www.github.com/rsennrich/nematus` 

### 2: Preprocess the parallel corpus:
1. Get the appropriate script in `code-docstring-corpus/scripts/nmt/`. Your options are `prepare_data_declbodies2desc.sh`, 
`prepare_data_decldesc2bodies.sh`, `prepare_data_desc2declbodies.sh`, `prepare_data_mono_declbodies2desc.sh`
2. If it is not already there, copy the script to the directory containing the data: `code-docstring-corpus/parallel-corpus`
3. In `code-docstring-corpus/parallel-corpus`, adapt the script to your project directory structure by changing `/path/to` in the following lines at the top:    
```
# Insert paths to tools
MOSES=/path/to/moses
BPE=/path/to/bpe
NEMATUS=/path/to/nematus
```
For example, 
```
# Insert paths to tools
MOSES=../../mosesdecoder
BPE=../../subword-nmt
NEMATUS=../../nematus
```
4. make the script executable with the command `chmod +x ./<SCRIPT>`
5. **unzip the `.train.gz` files** in `code-docstring-corpus/parallel-corpus`
6. run the script with the command `./<SCRIPT>`

### 3: Train the nmt model:
1. Get the appropriate script in `code-docstring-corpus/scripts/nmt/`. Your options are `train_declbodies2desc.sh`, 
`train_decldesc2bodies.sh`, `train_desc2declbodies.sh`, `train_decldesc2bodies_backtransl.sh`
2. If it is not already there, copy the script to the directory containing the data: `code-docstring-corpus/parallel-corpus`
3. In `code-docstring-corpus/parallel-corpus`, adapt the script to your project directory structure by changing `/path/to` in the following lines at the top: 
```
# Insert paths to nematus
NEMATUS=/path/to/nematus
```
For example,
```
# Insert paths to nematus
NEMATUS=../../nematus
```
4. Edit hyperparameters as needed. 
**Note**: You can remove `--max_epoch=10` at the very end of the script. We use it for testing the code.
```
$NEMATUS/nematus/nmt.py \
  --model data_ps.desc2declbodies.model.npz \
  --datasets data_ps.desc2declbodies.train.bpe.clean.d data_ps.desc2declbodies.train.bpe.clean.db \
  --valid_datasets data_ps.desc2declbodies.valid.bpe.d data_ps.desc2declbodies.valid.bpe.db \
  --dictionaries data_ps.desc2declbodies.train.bpe.clean.merged.json data_ps.desc2declbodies.train.bpe.clean.merged.json \
  --objective CE \
  --dim_word 400 \
  --dim 800 \
  --n_words_src 89500 \
  --n_words 89500 \
  --maxlen 300 \
  --batch_size 20 \
  --valid_batch_size 1 \
  --optimizer adam \
  --lrate 0.0001 \
  --validFreq 10000 \
  --dispFreq 1000 \
  --saveFreq=30000 \
  --sampleFreq=10000 \
  --use_dropout \
  --dropout_embedding=0.2 \
  --dropout_hidden=0.2 \
  --dropout_source=0.1 \
  --dropout_target=0.1 \
  --encoder_truncate_gradient 200 \
  --decoder_truncate_gradient 200 \
  --reload \
  --max_epoch=10
```
5. make the script executable with the command `chmod +x ./<SCRIPT>`
6. run the script with the command `./<SCRIPT>`

### Reference

If you use this corpus for a scientific publication, please cite: Miceli Barone, A. V. and Sennrich, R., 2017 "A parallel corpus of Python functions and documentation strings for automated code documentation and code generation" arXiv:1707.02275 https://arxiv.org/abs/1707.02275
