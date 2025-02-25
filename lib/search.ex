defmodule Search do
  use Hound.Helpers

  def search(query) do
    chromium_options = [
      prefs: %{
        "download.default_directory" => "/home/casa/ProjectsElixir/Automatiza-o-Elixir/download_dados"  # Caminho onde você deseja salvar os downloads
      }
    ]

    Hound.start_session(desired_capabilities: %{"goog:chromeOptions" => chromium_options})

    IO.puts("Sessão iniciada com sucesso!")

    try do
      navigate_to("https://emec.mec.gov.br/emec/nova")
      find_element(:id, "sel_sg_uf")
      |> click()

      find_element(:xpath, "//option[@value='#{query}']")
      |> click()

      find_element(:css, "input[name='data[CONSULTA_AVANCADA][chk_tp_natureza_gn][]'][value='3']") |> click()
      find_element(:css, "input[name='data[CONSULTA_AVANCADA][chk_tp_natureza_gn][]'][value='1']") |> click()
      find_element(:css, "input[name='data[CONSULTA_AVANCADA][chk_tp_natureza_gn][]'][value='2']") |> click()

      click({:id, "btnPesqAvancada"})

      :timer.sleep(10000)

      IO.puts "Clicando para exportar para Excel"
      find_element(:xpath, "//a[contains(@onclick, 'abrirPopUpExportarConsultaAvancada')]")
      |> click()

      :timer.sleep(5000)

    rescue
      error ->
        IO.puts("Erro ao realizar a busca: #{inspect(error)}")
    after
      Hound.end_session()
    end
  end
end
