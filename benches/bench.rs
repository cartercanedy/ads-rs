use std::{str::FromStr as _, time::Duration};

use criterion::{criterion_group, criterion_main, Criterion};

use ads::{AmsAddr, Client, Device, Source, Timeouts};
fn create_client() -> Client {
    Client::new("127.0.0.1:48898", Timeouts::new(Duration::from_millis(100)), Source::Request).unwrap()
}

fn create_device<'c>(client: &'c Client) -> Device<'c> {
    client.device(AmsAddr::from_str("127.0.0.1.1.1:351").unwrap())
}

fn write(crit: &mut Criterion) {
    let mut grp = crit.benchmark_group("write");
    grp
        .sample_size(500);

    let client = create_client();
    let device = create_device(&client);

    grp.bench_function("write", |bencher| {
        bencher.iter(|| {
            for i in 0..100 {
                device.write_value::<u32>(0x20000, 0, &(i as u32)).unwrap();
            }
        })
    });
}

fn read(crit: &mut Criterion) {
    let mut grp = crit.benchmark_group("read");
    grp.sample_size(500);

    let client = create_client();
    let device = create_device(&client);

    grp.bench_function("read", |bencher| {
        bencher.iter(|| {
            for _ in 0..100 {
                device.read_value::<u32>(0x20000, 0).unwrap();
            }
        })
    });
}

criterion_group!(benches, write, read);
criterion_main!(benches);
