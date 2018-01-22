module API
  module V1
    module Entities
      class Currency < Grape::Entity
        expose :id, documentation: { type: 'Integer' }
        expose :name, documentation: { type: 'String', desc: 'Full currency name' }
        expose :symbol, documentation: { type: 'String', desc: 'Currency code' }
      end

      class InstrumentHashBalance < Grape::Entity
        expose :id, documentation: { type: 'Integer' }
        expose :instrument_balance_id, documentation: { type: 'Integer', desc: 'ID of the instrument balance' }
        expose :hash_code, documentation: { type: 'String', desc: 'Hash code (market)' }
        expose :hash_amount, documentation: { type: 'Integer', desc: 'Instrument balance hash amount' }
        expose :hash_rate, documentation: { type: 'Float', desc: 'Hash rate' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Last update date time' }
      end

      class InstrumentBalance < Grape::Entity
        expose :id, documentation: { type: 'Integer' }
        expose :currency_id, documentation: { type: 'Integer', desc: 'Balance currency ID' }
        expose :instrument_id, documentation: { type: 'Integer', desc: 'Balance instrument ID' }
        expose :amount, documentation: { type: 'Float', desc: 'Current instrument currency balance amount' }
        expose :updated_at, documentation: { type: 'DateTime', desc: 'Last update date time' }
        expose :instrument_hash_balances,
          using: API::V1::Entities::InstrumentHashBalance, 
          if: lambda { |instance, _options| instance.instrument.instrument_type.bixin? || instance.instrument.instrument_type.hashnest? }
      end

      class Instrument < Grape::Entity
        expose :id, documentation: { type: 'Integer' }
        expose :name, documentation: { type: 'String', desc: 'Instrument name' }
        expose :notes, documentation: { type: 'String', desc: 'Instrument description' }
        expose :instrument_type, documentation: { type: 'String',  desc: 'Instrument type'}
      end

      class InstrumentBalanceUpdateSuccess < Grape::Entity
        expose :code, documentation: { type: 'String', desc: 'Response code' } do
          'ok'
        end
        expose :instrument_balance, using: API::V1::Entities::InstrumentBalance
      end
    end
  end
end
