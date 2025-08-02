# A Machine Learning Classification Model for Gold-Binding Peptides

**Author:** Ali Ahmadi Esfidi
**Date:** May 2025

---

## Overview

This repository contains the source for a project on the development, evaluation, and interpretation of machine learning models designed to classify gold-binding peptides.

## Background

Gold-binding peptides are short amino acid sequences that specifically adhere to gold surfaces or nanoparticles. They find applications in:

* **Nano‑templating & Nanofabrication**
* **Biosensing & Diagnostics**
* **Targeted Drug Delivery & Imaging**
* **Surface Functionalization**

The project frames this as a binary classification problem using spot‑array binding intensity measurements (arbitrary units) to label peptides based on a median threshold (209,500 units).

## Dataset

* **Source:** Supplementary material from ACS Omega article by Janairo et al.
* **Size:** 1,720 unique 10‑mer peptides.
* **Labels:** 861 strong binders (Class A) and 859 weak/non‑binders (Class B).
* **Intensity Threshold:** Median intensity $I_{med} = 207,500$.

## Feature Engineering

Three embedding strategies were used, either standalone or combined:

1. **Amino Acid Composition (AAC)** – frequency vector (length 20).
2. **Kidera Factors** – 10 physicochemical descriptors.
3. **BLOSUM62 Encoding** – substitution matrix rows as 20‑dimensional vectors.

## Model Architectures

1. **Baseline (Related Work)** – radial-basis SVM with Kidera factors and 10‑fold CV.
2. **XGBoost Classifier** – gradient‑boosted trees with ROC AUC tuning.
3. **Support Vector Machine (SVM)** – kernelized, mutual information feature selection.
4. **Residual Attention Neural Network** – deep network with residual and attention blocks.
5. **Siamese‑like Neural Network** – three-branch architecture for AAC, Kidera, and BLOSUM features.

## Training & Evaluation

* **Preprocessing:**

  * Stratified splits (train/validation/test).
  * StandardScaler fit on training data.
  * SelectKBest via mutual information for feature selection.
* **Optimization:** GridSearchCV for hyperparameters, ROC AUC metric, class weighting strategies.
* **Augmentation (NNs):** Gaussian noise, Mixup.
* **Regularization:** Dropout, early stopping, gradient clipping.

## Results

Comparative performance on test set:

| Model                 | Accuracy  | F1‑Macro  | Precision | Recall     | True Positives |
| --------------------- | --------- | --------- | --------- | ---------- | -------------- |
| Baseline (SVM)        | 0.802     | 0.802     | 0.796     | 0.811      | 344            |
| XGBoost               | 0.819     | 0.8184    | 0.799     | 0.851      | 352            |
| SVM                   | 0.828     | 0.8279    | 0.822     | 0.837      | 356            |
| Residual Attention NN | 0.833     | 0.832     | 0.8095    | 0.8698     | 358            |
| **Siamese‑like NN**   | **0.840** | **0.839** | 0.809     | **0.8884** | **361**        |

## Interpretation

* **Permutation Importance** and **SHAP** analyses identified:

  * **KF3 (Extended Structure Preference)**
  * **KF4 (Hydrophobicity)**
  * **KF7 (Flat Extended Preference)**
  * **BLOSUM62\_R**
  * **KF9 (C‑terminal pKa)**

These features most strongly influence the Siamese‑like model’s predictions.

## Future Work

* Integrate **structural embeddings** (e.g., from AlphaFold).
* Explore **sequence‑based CNNs** or **transformer** architectures.
* Validate model on **external peptide screens** or **in vitro** assays.

---

© May 2025, Ali Ahmadi Esfidi
