Nx.global_default_backend(EXLA.Backend)

IO.puts("Running inference example:")
{:ok, model_info} = Bumblebee.load_model({:hf, "eliasalbouzidi/distilbert-nsfw-text-classifier"})

{:ok, tokenizer} =
  Bumblebee.load_tokenizer({:hf, "eliasalbouzidi/distilbert-nsfw-text-classifier"})

serving = Bumblebee.Text.text_classification(model_info, tokenizer)

IO.inspect(serving)

text = "I see you’ve set aside this special time to humiliate yourself in public."

IO.puts("Starting inference:")

serving |> Nx.Serving.run(text) |> IO.inspect()

serving |> Nx.Serving.run("gay") |> IO.inspect()
