{application,pool_proj,
             [{applications,[kernel,stdlib,elixir,logger,nimble_csv]},
              {description,"pool_proj"},
              {modules,['Elixir.CSVReader','Elixir.MyCSVParser',
                        'Elixir.PoolChemistryChecker','Elixir.PoolMonitor',
                        'Elixir.PoolProj','Elixir.PoolSimulator']},
              {registered,[]},
              {vsn,"0.1.0"}]}.
