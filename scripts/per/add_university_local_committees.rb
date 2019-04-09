data = CSV.read("#{Rails.root}/scripts/per/uni_lc.csv")

data.shift

data.each do |uni_lc|
  university = University.find_by(expa_id: uni_lc[0].to_i)
  university_id = university.try(:id)

  gv_committee_id = LocalCommittee.find_by('unaccent(name) ilike unaccent(?)',  uni_lc[1]).id
  ge_committee_id = LocalCommittee.find_by('unaccent(name) ilike unaccent(?)',  uni_lc[2]).id
  gt_committee_id = LocalCommittee.find_by('unaccent(name) ilike unaccent(?)',  uni_lc[3]).id

  if university_id
    UniversityLocalCommittee.create(university_id: university_id, local_committee_id: gv_committee_id, program: 0)
    UniversityLocalCommittee.create(university_id: university_id, local_committee_id: ge_committee_id, program: 1)
    UniversityLocalCommittee.create(university_id: university_id, local_committee_id: gt_committee_id, program: 2)
  end
end
