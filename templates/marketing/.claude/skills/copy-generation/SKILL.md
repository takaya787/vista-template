---
name: copy-generation
description: Generate ad copy variants for a given campaign brief. Use when the user says "/copy-generation", "広告コピーを作成して", "コピーのバリエーション作って", or "generate ad copy".
---

# Ad Copy Generator

キャンペーンブリーフからチャネル別広告コピーを複数バリエーション生成する。

## Why This Skill Is Needed

コピー制作は試行回数が品質に直結する。ブリーフの構造化とチャネル制約の適用を自動化することで、バリエーション生成にかかる時間を削減し、A/Bテスト設計まで一貫して支援する。

## Data Sources

- **ブリーフ** — ユーザーからのインプット（または `inbox/` の資料）
- **チャネル設定** — `rules/config/channels.md`（文字数制限の参照）

## Steps

### Step 1: ブリーフ確認

以下が揃っているか確認。不足があればユーザーに質問する:

- 商品・サービス名
- ターゲットペルソナ（簡潔に）
- 訴求したい便益（1つに絞る）
- 対象チャネル

### Step 2: 文字数制約の適用

| チャネル      | Headline | Body      |
| ------------- | -------- | --------- |
| Google Search | 30字以内 | 90字以内  |
| Meta          | 40字以内 | 125字以内 |
| LINE          | 20字以内 | 60字以内  |

### Step 3: バリエーション生成

最低5バリエーションをテーブル形式で生成。訴求軸を変えること（価格・感情・機能・社会的証明・緊急性）。

### Step 4: 出力・確認

ユーザーに確認を取り、採用バリエーションを `inbox/copy_{campaign-name}_{YYYY-MM-DD}.md` に保存。
