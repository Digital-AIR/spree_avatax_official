require 'spec_helper'

describe SpreeAvataxOfficial::ItemPresenter do
  subject { described_class.new(item: item) }

  describe '#to_json' do
    context 'with line item' do
      let(:item) { create(:line_item) }

      let(:result) do
        {
          number:     "LI-#{item.avatax_uuid}",
          quantity:   item.quantity,
          amount:     item.discounted_amount,
          taxCode:    'P0000000',
          discounted: false,
          addresses:  {}
        }
      end

      context 'without line item tax code' do
        it 'serializes the object' do
          expect(subject.to_json).to eq result
        end
      end

      context 'with line item tax code' do
        it 'serializes the object' do
          item.tax_category.tax_code = 'P0000001'

          result[:taxCode] = 'P0000001'

          expect(subject.to_json).to eq result
        end
      end

      context 'with line item quantity' do
        subject { described_class.new(item: item, custom_quantity: quantity) }

        let(:quantity) { item.quantity - 1 }

        it 'serializes the object' do
          result[:quantity] = quantity

          expect(subject.to_json).to eq result
        end

        context 'with line item amount' do
          subject { described_class.new(item: item, custom_quantity: quantity, custom_amount: amount) }

          let(:quantity) { item.quantity - 1 }
          let(:amount) { item.amount * 2 }

          it 'serializes the object' do
            result[:quantity] = quantity
            result[:amount]   = amount

            expect(subject.to_json).to eq result
          end
        end
      end

      context 'when line item has inventory_units' do
        let(:ship_from_address) { SpreeAvataxOfficial::AddressPresenter.new(address: stock_location_address, address_type: 'ShipFrom').to_json }
        let(:ship_to_address)   { SpreeAvataxOfficial::AddressPresenter.new(address: item.order.tax_address, address_type: 'ShipTo').to_json }
        let(:stock_location)    { item.inventory_units.first.shipment.stock_location }
        let(:stock_location_address) do
          {
            line1:      stock_location.address1,
            line2:      stock_location.address2,
            city:       stock_location.city,
            region:     stock_location.state.try(:abbr),
            country:    stock_location.country.try(:iso),
            postalCode: stock_location.zipcode
          }
        end
        let(:item) do
          create(:line_item).tap do |line_item|
            line_item.order.ship_address = create(:usa_address)
            create(:inventory_unit, order: line_item.order, line_item: line_item)
          end
        end

        it 'serializes the object' do
          result[:addresses] = ship_from_address.merge(ship_to_address)

          expect(subject.to_json).to eq result
        end
      end
    end

    context 'with shipment' do
      let(:item) { create(:avatax_shipment) }

      let(:result) do
        {
          number:     "FR-#{item.avatax_uuid}",
          quantity:   1,
          amount:     item.discounted_amount,
          taxCode:    'FR',
          discounted: false,
          addresses:  {}
        }
      end

      it 'serializes the object' do
        expect(subject.to_json).to eq result
      end
    end
  end
end
