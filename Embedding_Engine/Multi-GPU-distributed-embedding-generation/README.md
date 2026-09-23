# Multi-GPU Distributed Embedding Engine for Semantic Search using PyTorch

A production-style NLP project that builds a semantic search engine over real-world text data using PyTorch transformer embeddings, FAISS vector search, and multi-GPU distributed embedding generation.

The project uses the MS MARCO public information retrieval dataset and demonstrates how large-scale document embeddings can be generated efficiently using single-GPU and multi-GPU workflows.

---

## Project Overview

Traditional keyword search retrieves documents based on exact word overlap. Semantic search retrieves documents based on meaning.

This project converts passages and user queries into dense vector embeddings using a transformer model. These embeddings are indexed with FAISS, allowing fast top-k similarity search.

The project includes:

- Real-world public dataset: MS MARCO passages
- PyTorch Dataset and DataLoader pipeline
- Transformer-based embedding generation
- Mean pooling over contextual token embeddings
- FAISS vector indexing
- Semantic query search
- Search latency benchmarking
- Multi-GPU distributed passage embedding using `torchrun`
- Single-GPU vs distributed workflow comparison

---

## Tech Stack

- Python
- PyTorch
- Hugging Face Transformers
- MS MARCO dataset
- FAISS
- pandas
- NumPy
- tqdm
- torch.distributed
- torchrun
- Kaggle Notebook with GPU support

---

## Dataset

The project uses the MS MARCO public retrieval dataset.

For the initial benchmark, 10,000 passages were used.

```python
corpus = load_dataset(
    "sentence-transformers/msmarco",
    "corpus",
    split="train[:10000]"
)
```

Each record contains:

```text
passage_id
passage
```

---

## Model

The embedding model used:

```text
sentence-transformers/all-MiniLM-L6-v2
```

Embedding dimension:

```text
384
```

The model produces contextual token embeddings. Mean pooling is applied over the final hidden states to create one dense vector per passage or query.

---

## Project Architecture

```text
MS MARCO passages
        ↓
PyTorch Dataset + DataLoader
        ↓
Transformer model
        ↓
Contextual token embeddings
        ↓
Mean pooling
        ↓
Normalized passage embeddings
        ↓
FAISS vector index
        ↓
User query embedding
        ↓
Top-k semantic search results
```

---

## Multi-GPU Distributed Embedding

The distributed version uses `torchrun`, `torch.distributed`, and `DistributedSampler`.

Each GPU process receives a shard of the dataset and generates embeddings independently.

```bash
torchrun --nproc_per_node=2 /kaggle/working/embed_distributed.py \
    --input_csv /kaggle/working/data/passages.csv \
    --output_dir /kaggle/working/distributed_outputs \
    --batch_size 64 \
    --max_length 256
```

Distributed architecture:

```text
Process 0 → GPU 0 → passage shard 1 → embeddings_rank_0.npy
Process 1 → GPU 1 → passage shard 2 → embeddings_rank_1.npy
```

The saved outputs are later loaded and combined to build a FAISS index.

Important implementation detail:

The distributed script converts `passage_id` tensors back into normal Python values before saving metadata.

```python
batch_passage_ids = batch["passage_id"]

if torch.is_tensor(batch_passage_ids):
    batch_passage_ids = batch_passage_ids.cpu().tolist()

local_passage_ids.extend(batch_passage_ids)
```

This prevents metadata merge issues such as `tensor(6052)` not matching `6052`.

---

## FAISS Indexing

The passage embeddings are normalized and indexed using FAISS `IndexFlatIP`.

```python
embedding_dim = embeddings_matrix.shape[1]

index = faiss.IndexFlatIP(embedding_dim)
index.add(embeddings_matrix)
```

Because embeddings are L2-normalized, inner product behaves like cosine similarity.

---

## Query Embedding and Semantic Search

A user query is embedded using the same tokenizer, transformer model, mean pooling, and normalization.

```python
def embed_query(query):
    encoded = tokenizer(
        query,
        padding=True,
        truncation=True,
        max_length=256,
        return_tensors="pt"
    )

    input_ids = encoded["input_ids"].to(device)
    attention_mask = encoded["attention_mask"].to(device)

    with torch.no_grad():
        outputs = model(input_ids=input_ids, attention_mask=attention_mask)
        query_embedding = mean_pooling(outputs, attention_mask)
        query_embedding = F.normalize(query_embedding, p=2, dim=1)

    return query_embedding.cpu().numpy().astype("float32")
```

Search function:

```python
def semantic_search_distributed_index(query, top_k=5):
    query_vector = embed_query(query)

    scores, indices = distributed_index.search(query_vector, top_k)

    results = []

    for score, idx in zip(scores[0], indices[0]):
        row = distributed_metadata.iloc[int(idx)]

        results.append({
            "passage_id": row["passage_id"],
            "score": float(score),
            "passage": str(row["passage"])
        })

    return results
```

---

## Search Benchmark

Single-GPU search benchmark:

```text
Total queries: 10
Average search latency: 7.12 ms
Minimum latency: 5.83 ms
Maximum latency: 10.64 ms
```

Distributed-index search benchmark:

```text
Total queries: 10
Average distributed search latency: 8.31 ms
Minimum distributed search latency: 7.35 ms
Maximum distributed search latency: 12.80 ms
```

Note: Multi-GPU improves offline passage embedding generation. Query-time semantic search is a small workload, so it is usually handled using a single process. The distributed index search latency remains low at approximately 8 ms.

---

## Repository Structure

```text
multi-gpu-embedding-engine/
│
├── notebooks/
│   └── multi-gpu-embedding-engine.ipynb
│
├── src/
│   ├── embed_distributed.py
│   ├── build_index.py
│   ├── search.py
│   └── utils.py
│
├── data/
│   └── passages.csv
│
├── distributed_outputs/
│   ├── embeddings_rank_0.npy
│   ├── embeddings_rank_1.npy
│   ├── passage_ids_rank_0.csv
│   └── passage_ids_rank_1.csv
│
├── artifacts/
│   ├── msmarco_faiss.index
│   └── metadata.pkl
│
├── requirements.txt
└── README.md
```

---
