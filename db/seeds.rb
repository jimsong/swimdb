events = [
  [50, 'SCY', 'Free', false],
  [100, 'SCY', 'Free', false],
  [200, 'SCY', 'Free', false],
  [500, 'SCY', 'Free', false],
  [1000, 'SCY', 'Free', false],
  [1650, 'SCY', 'Free', false],
  [50, 'SCY', 'Fly', false],
  [100, 'SCY', 'Fly', false],
  [200, 'SCY', 'Fly', false],
  [50, 'SCY', 'Back', false],
  [100, 'SCY', 'Back', false],
  [200, 'SCY', 'Back', false],
  [50, 'SCY', 'Breast', false],
  [100, 'SCY', 'Breast', false],
  [200, 'SCY', 'Breast', false],
  [100, 'SCY', 'IM', false],
  [200, 'SCY', 'IM', false],
  [400, 'SCY', 'IM', false],
  [200, 'SCY', 'Free', true],
  [400, 'SCY', 'Free', true],
  [800, 'SCY', 'Free', true],
  [200, 'SCY', 'Medley', true],
  [400, 'SCY', 'Medley', true],

  [50, 'LCM', 'Free', false],
  [100, 'LCM', 'Free', false],
  [200, 'LCM', 'Free', false],
  [400, 'LCM', 'Free', false],
  [800, 'LCM', 'Free', false],
  [1500, 'LCM', 'Free', false],
  [50, 'LCM', 'Fly', false],
  [100, 'LCM', 'Fly', false],
  [200, 'LCM', 'Fly', false],
  [50, 'LCM', 'Back', false],
  [100, 'LCM', 'Back', false],
  [200, 'LCM', 'Back', false],
  [50, 'LCM', 'Breast', false],
  [100, 'LCM', 'Breast', false],
  [200, 'LCM', 'Breast', false],
  [200, 'LCM', 'IM', false],
  [400, 'LCM', 'IM', false],
  [200, 'LCM', 'Free', true],
  [400, 'LCM', 'Free', true],
  [800, 'LCM', 'Free', true],
  [200, 'LCM', 'Medley', true],
  [400, 'LCM', 'Medley', true],
  
  [50, 'SCM', 'Free', false],
  [100, 'SCM', 'Free', false],
  [200, 'SCM', 'Free', false],
  [400, 'SCM', 'Free', false],
  [800, 'SCM', 'Free', false],
  [1500, 'SCM', 'Free', false],
  [50, 'SCM', 'Fly', false],
  [100, 'SCM', 'Fly', false],
  [200, 'SCM', 'Fly', false],
  [50, 'SCM', 'Back', false],
  [100, 'SCM', 'Back', false],
  [200, 'SCM', 'Back', false],
  [50, 'SCM', 'Breast', false],
  [100, 'SCM', 'Breast', false],
  [200, 'SCM', 'Breast', false],
  [100, 'SCM', 'IM', false],
  [200, 'SCM', 'IM', false],
  [400, 'SCM', 'IM', false],
  [200, 'SCM', 'Free', true],
  [400, 'SCM', 'Free', true],
  [800, 'SCM', 'Free', true],
  [200, 'SCM', 'Medley', true],
  [400, 'SCM', 'Medley', true],
]

events.each do |event|
  distance = event[0]
  course = event[1]
  stroke = event[2]
  relay = event[3]

  Event.find_or_create_by(
    distance: distance,
    course: course,
    stroke: stroke,
    relay: relay
  )
end

age_groups = [
  ['M', 18, 24, false],
  ['M', 25, 29, false],
  ['M', 30, 34, false],
  ['M', 35, 39, false],
  ['M', 40, 44, false],
  ['M', 45, 49, false],
  ['M', 50, 54, false],
  ['M', 55, 59, false],
  ['M', 60, 64, false],
  ['M', 65, 69, false],
  ['M', 70, 74, false],
  ['M', 75, 79, false],
  ['M', 80, 84, false],
  ['M', 85, 89, false],
  ['M', 90, 94, false],
  ['M', 95, 99, false],
  ['M', 100, 104, false],
  ['W', 18, 24, false],
  ['W', 25, 29, false],
  ['W', 30, 34, false],
  ['W', 35, 39, false],
  ['W', 40, 44, false],
  ['W', 45, 49, false],
  ['W', 50, 54, false],
  ['W', 55, 59, false],
  ['W', 60, 64, false],
  ['W', 65, 69, false],
  ['W', 70, 74, false],
  ['W', 75, 79, false],
  ['W', 80, 84, false],
  ['W', 85, 89, false],
  ['W', 90, 94, false],
  ['W', 95, 99, false],
  ['W', 100, 104, false],
  ['M', 18, nil, true],
  ['M', 25, nil, true],
  ['M', 35, nil, true],
  ['M', 45, nil, true],
  ['M', 55, nil, true],
  ['M', 65, nil, true],
  ['M', 75, nil, true],
  ['M', 85, nil, true],
  ['W', 18, nil, true],
  ['W', 25, nil, true],
  ['W', 35, nil, true],
  ['W', 45, nil, true],
  ['W', 55, nil, true],
  ['W', 65, nil, true],
  ['W', 75, nil, true],
  ['W', 85, nil, true],
  ['X', 18, nil, true],
  ['X', 25, nil, true],
  ['X', 35, nil, true],
  ['X', 45, nil, true],
  ['X', 55, nil, true],
  ['X', 65, nil, true],
  ['X', 75, nil, true],
  ['X', 85, nil, true],
  ['M', 72, 99, true],
  ['M', 100, 119, true],
  ['M', 120, 159, true],
  ['M', 160, 199, true],
  ['M', 200, 239, true],
  ['M', 240, 279, true],
  ['M', 280, 319, true],
  ['M', 320, 359, true],
  ['M', 360, 399, true],
  ['W', 72, 99, true],
  ['W', 100, 119, true],
  ['W', 120, 159, true],
  ['W', 160, 199, true],
  ['W', 200, 239, true],
  ['W', 240, 279, true],
  ['W', 280, 319, true],
  ['W', 320, 359, true],
  ['W', 360, 399, true],
  ['X', 72, 99, true],
  ['X', 100, 119, true],
  ['X', 120, 159, true],
  ['X', 160, 199, true],
  ['X', 200, 239, true],
  ['X', 240, 279, true],
  ['X', 280, 319, true],
  ['X', 320, 359, true],
  ['X', 360, 399, true],
]

age_groups.each do |age_group|
  gender = age_group[0]
  start_age = age_group[1]
  end_age = age_group[2]
  relay = age_group[3]

  AgeGroup.find_or_create_by(
    gender: gender,
    start_age: start_age,
    end_age: end_age,
    relay: relay
  )
end
