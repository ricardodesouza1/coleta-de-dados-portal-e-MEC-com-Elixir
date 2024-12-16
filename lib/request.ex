defmodule Request do
  use Hound.Helpers
  require Logger
  use HTTPoison.Base

  @url "https://emec.mec.gov.br/emec/nova-index/gerar-arquivo-relatorio-consultar-avancada"
  @output_path "download_dados/response.txt"
    def post_request do
    # Configurar os parâmetros do POST
    params = %{
      "data[CONSULTA_AVANCADA_HIDDEN][template]" => "listar-consulta-avancada-ies",
      "data[CONSULTA_AVANCADA_HIDDEN][order]" => "ies.no_ies ASC",
      "data[CONSULTA_AVANCADA_HIDDEN][no_cidade_avancada]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][no_regiao_avancada]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][no_pais_avancada]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][co_pais_avancada]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][buscar_por]" => "IES",
      "data[CONSULTA_AVANCADA_HIDDEN][no_ies]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][no_ies_curso]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][no_ies_curso_especializacao]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][no_curso]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][co_area_geral]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][co_area_especifica]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][co_area_detalhada]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][co_area_curso]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][no_especializacao]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][co_area]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][sg_uf]" => "AM",
      "data[CONSULTA_AVANCADA_HIDDEN][co_municipio]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][st_gratuito]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][no_indice_ies]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][no_indice_curso]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][co_situacao_funcionamento_ies]" => "10035",
      "data[CONSULTA_AVANCADA_HIDDEN][co_situacao_funcionamento_curso]" => "9",
      "data[CONSULTA_AVANCADA_HIDDEN][st_funcionamento_especializacao]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][ds_origem]" => "Avancada",
      "data[CONSULTA_AVANCADA_HIDDEN][ds_objeto]" => "IES",
      "data[CONSULTA_AVANCADA_HIDDEN][no_cidade]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][no_regiao]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][no_pais]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][co_pais]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][page]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][list]" => "",
      "data[CONSULTA_AVANCADA_HIDDEN][hid_format_ext]" => "xls",
      "data[CONSULTA_AVANCADA_HIDDEN][hid_st_nome_consulta]" => "ies"
    }

    # Adicionar a lista manualmente
    list_params = [
      {"data[CONSULTA_AVANCADA_HIDDEN][tp_natureza_gn][]", "3"},
      {"data[CONSULTA_AVANCADA_HIDDEN][tp_natureza_gn][]", "1"},
      {"data[CONSULTA_AVANCADA_HIDDEN][tp_natureza_gn][]", "2"}
    ]

    # Combinar os parâmetros com os campos individuais
    query = URI.encode_query(params) <> "&" <> encode_list(list_params)

    # Cabeçalhos da requisição
    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]

    # Fazer a requisição POST
    case HTTPoison.post(@url, query, headers, recv_timeout: 30_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        Logger.info("Requisição bem-sucedida.")
        save_response_to_file(response_body, @output_path)
        {:ok, response_body}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Logger.error("Erro: Código de status #{status_code}")
        {:error, "Erro na requisição"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Erro ao realizar a requisição: #{inspect(reason)}")
        {:error, "Erro ao realizar a requisição"}
    end
  end

   # Função para salvar a resposta em um arquivo de texto
  defp save_response_to_file(response_body, path) do
    File.mkdir_p!(Path.dirname(path)) # Garante que o diretório exista

    case File.write(path, response_body) do
      :ok ->
        Logger.info("""
        ============================
        🟢 Resposta salva com sucesso!
        ============================
        Caminho do Arquivo: #{path}
        """)

      {:error, reason} ->
        Logger.error("""
        ============================
        ❌ Falha ao salvar a resposta
        ============================
        Motivo: #{inspect(reason)}
        """)
    end
  end

  # Função auxiliar para codificar listas em parâmetros de consulta
  defp encode_list(list) do
    list
    |> Enum.map(fn {key, value} -> "#{URI.encode(key)}=#{URI.encode(value)}" end)
    |> Enum.join("&")
  end

  def search(query) do
    # Inicia uma sessão do WebDriver
    chromium_options = [
      prefs: %{
        "download.default_directory" => "/home/casa/ProjectsElixir/request/download_dados"  # Caminho onde você deseja salvar os downloads
      }
    ]
    # Hound.start_session(desired_capabilities: chromium_options)
    # Iniciando a sessão com as opções configuradas
    Hound.start_session(desired_capabilities: %{"goog:chromeOptions" => chromium_options})

    IO.puts("Sessão iniciada com sucesso!")

    try do
      # Acessa o portal de cadastro nacinal de instituições ensino superior MEC
      navigate_to("https://emec.mec.gov.br/emec/nova")
      # Clicar no select
      find_element(:id, "sel_sg_uf")
      |> click()

      # Selecionando a opção desejada preenchendo o valor
      find_element(:xpath, "//option[@value='#{query}']")
      |> click()

      # Selecionar categoria admistrativa
      find_element(:css, "input[name='data[CONSULTA_AVANCADA][chk_tp_natureza_gn][]'][value='3']") |> click()
      find_element(:css, "input[name='data[CONSULTA_AVANCADA][chk_tp_natureza_gn][]'][value='1']") |> click()
      find_element(:css, "input[name='data[CONSULTA_AVANCADA][chk_tp_natureza_gn][]'][value='2']") |> click()

      click({:id, "btnPesqAvancada"})


      # Aguarda um momento para que os resultados sejam carregados
      :timer.sleep(10000)

      IO.puts "Clicando para exportar para Excel"
      find_element(:xpath, "//a[contains(@onclick, 'abrirPopUpExportarConsultaAvancada')]")
      |> click()

      :timer.sleep(5000)

    rescue
      error ->
        IO.puts("Erro ao realizar a busca: #{inspect(error)}")
    after
      # Finaliza a sessão
      Hound.end_session()
    end
  end
end
