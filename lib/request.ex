defmodule Request do
  require Logger
  use HTTPoison.Base

  @url "https://emec.mec.gov.br/emec/nova-index/gerar-arquivo-relatorio-consultar-avancada"
  @output_path_csv "download_dados/dados.csv"

  def buscar_ies(sg_ufs) do
    resultados =
      sg_ufs
      |> Enum.map(fn uf -> Task.async(fn -> requisicao_emec(uf) end) end)
      |> Enum.map(&Task.await/1)

    htmls_por_estado =
      resultados
      |> Enum.filter(fn
        {:ok, _uf, _response_body} -> true
        _ -> false
      end)

    cabecalhos =
      case List.first(htmls_por_estado) do
        {:ok, _uf, html} ->
          ["UF" | extrair_cabecalhos(html)]

        nil ->
          Logger.error("Nenhuma tabela encontrada nos resultados")
          []
      end

    tabelas =
      htmls_por_estado
      |> Enum.flat_map(fn {:ok, uf, html} ->
        extrair_tabela(html, uf)
      end)

    gerar_csv([cabecalhos | tabelas], @output_path_csv)
  end
  def requisicao_emec(sg_uf) do
    params = %{
      "data[CONSULTA_AVANCADA_HIDDEN][template]" => "listar-consulta-avancada-ies",
      "data[CONSULTA_AVANCADA_HIDDEN][order]" => "ies.no_ies ASC",
      "data[CONSULTA_AVANCADA_HIDDEN][buscar_por]" => "IES",
      "data[CONSULTA_AVANCADA_HIDDEN][sg_uf]" => sg_uf,
      "data[CONSULTA_AVANCADA_HIDDEN][co_situacao_funcionamento_ies]" => "10035",
      "data[CONSULTA_AVANCADA_HIDDEN][co_situacao_funcionamento_curso]" => "9",
      "data[CONSULTA_AVANCADA_HIDDEN][ds_origem]" => "Avancada",
      "data[CONSULTA_AVANCADA_HIDDEN][ds_objeto]" => "IES",
      "data[CONSULTA_AVANCADA_HIDDEN][hid_format_ext]" => "xls",
      "data[CONSULTA_AVANCADA_HIDDEN][hid_st_nome_consulta]" => "ies"
    }

    list_params = [
      {"data[CONSULTA_AVANCADA_HIDDEN][tp_natureza_gn][]", "3"},
      {"data[CONSULTA_AVANCADA_HIDDEN][tp_natureza_gn][]", "1"},
      {"data[CONSULTA_AVANCADA_HIDDEN][tp_natureza_gn][]", "2"}
    ]

    query = URI.encode_query(params) <> "&" <> encode_list(list_params)

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    case HTTPoison.post(@url, query, headers, recv_timeout: 30_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        Logger.info("Requisição bem-sucedida para #{sg_uf}!")
        {:ok, sg_uf, response_body}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Logger.error("Erro na requisição para #{sg_uf}. Código de status #{status_code}")
        {:error, sg_uf, "Erro na requisição"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Erro ao realizar a requisição para #{sg_uf}: #{inspect(reason)}")
        {:error, sg_uf, "Erro ao realizar a requisição"}
    end
  end

  defp encode_list(list) do
    list
    |> Enum.map(fn {key, value} -> "#{URI.encode(key)}=#{URI.encode(value)}" end)
    |> Enum.join("&")
  end

  defp extrair_cabecalhos(html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("table#tbDataGridNova thead th")
    |> Enum.map(&Floki.text/1)
    |> Enum.map(&String.trim/1)
  end

  defp extrair_tabela(html, estado) do
    document = Floki.parse_document!(html)

    linhas =
      document
      |> Floki.find("table#tbDataGridNova tbody tr")
      |> Enum.map(fn tr ->
        tr
        |> Floki.find("td")
        |> Enum.map(&Floki.text/1)
        |> Enum.map(&String.trim/1)
        |> List.insert_at(0, estado)
      end)

    linhas
  end

  defp gerar_csv(tabela, caminho_csv) do
    try do
      File.mkdir_p!(Path.dirname(caminho_csv))
      File.write!(caminho_csv, CSV.encode(tabela) |> Enum.join())
      Logger.info("CSV consolidado salvo com sucesso: #{caminho_csv}")
      :ok
    rescue
      exception ->
        Logger.error("Erro ao salvar o CSV: #{Exception.message(exception)}")
        {:error, Exception.message(exception)}
    end
  end

end
