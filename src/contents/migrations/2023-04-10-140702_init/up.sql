-- Your SQL goes here
create table plants (
    plant_id integer primary key autoincrement not null,
    name text not null,
    species text not null,
    img_url text,
    water_intervall integer not null,
    location text,
    date_of_birth integer,
    parent integer
);

create table water_history (
    plant_id integer not null,
    water_date integer not null,
    foreign key (plant_id) references plants(plant_id)
);

create table health_history (
    plant_id integer not null,
    health_date integer not null,
    health integer not null,
    foreign key (plant_id) references plants(plant_id)
);
