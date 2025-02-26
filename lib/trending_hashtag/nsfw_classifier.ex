defmodule TrendingHashtag.NsfwClassifier do
  @moduledoc false
  def serving do
    {:ok, model_info} =
      Bumblebee.load_model({:hf, "eliasalbouzidi/distilbert-nsfw-text-classifier"})

    {:ok, tokenizer} =
      Bumblebee.load_tokenizer({:hf, "eliasalbouzidi/distilbert-nsfw-text-classifier"})

    Bumblebee.Text.text_classification(model_info, tokenizer)
  end
end
