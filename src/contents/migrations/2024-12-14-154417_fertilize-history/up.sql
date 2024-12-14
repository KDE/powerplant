create table fertilizer_history (
    plant_id integer not null,
    fertilizer_date integer not null,
    foreign key (plant_id) references plants(plant_id)
);

alter table plants add fertilizer_interval integer;
