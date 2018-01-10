require 'csv'

desc 'load data into salt spray test database from CSV file'
task load_sst_data: :environment do
  CSV.foreach('/home/brendan/Desktop/sst_data.csv', headers: true) do |row|
    row_hash = row.to_hash
    if !row_hash["S.O. #"].nil? && row_hash["S.O. #"].start_with?('2') && row_hash["Part ID"].present? && last_quarter(row.to_hash["Date On"])
      pulled_off_by_val = 27 if row_hash["Date Off"].present?
      marked_white_by_val = 27 if row_hash["Date w/ White"].present?
      marked_red_by_val = 27 if row_hash["Date w/ Red"].present?
      date_on_val = row_hash["Date On"].insert(6, '20') if !row_hash["Date On"].nil?
      date_off_val = row_hash["Date Off"].insert(6, '20') if !row_hash["Date Off"].nil?
      date_w_white_val = row_hash["Date w/ White"].insert(6, '20') if !row_hash["Date w/ White"].nil?
      date_w_red_val = row_hash["Date w/ Red"].insert(6, '20') if !row_hash["Date w/ Red"].nil?
      SaltSprayTest.create({
        shop_order_number: row_hash["S.O. #"],
        load_number: row_hash["Load #"] || 1,
        customer: row_hash["Customer"],
        process_code: row_hash["Process"],
        part_number: row_hash["Part ID"],
        sub: row_hash["Sub"],
        put_on_by: 27,
        put_on_at: date_on_val,
        pulled_off_by: pulled_off_by_val,
        pulled_off_at: date_off_val,
        white_spec: row_hash["White Spec"],
        red_spec: row_hash["Red Spec"],
        dept: row_hash["Dept"],
        marked_white_by: marked_white_by_val,
        marked_white_at: date_w_white_val,
        marked_red_by: marked_red_by_val,
        marked_red_at: date_w_red_val
      })
    end
  end
end

def last_quarter(date_on_hash)
  date_on_hash[0..1].to_i >= 10 && date_on_hash[6..7].to_i >= 17
end