#[macro_use]
extern crate rustler;

extern crate atomic_counter;

use rustler::{Env, Term, NifResult, Encoder, ResourceArc};
use atomic_counter::{AtomicCounter, RelaxedCounter};


struct CounterResource {
    counter: RelaxedCounter,
}

mod atoms {
    rustler_atoms! {
        atom ok;
    }
}

rustler_export_nifs! {
    "ecounter_nif", // module name
    [
        ("new", 0, new),
        ("get", 1, get),
        ("reset", 1, reset),
        ("add", 2, add)
    ], // nif functions
    Some(on_load) // on_load callback
}

// callback: called on loading nif library
fn on_load(env: Env, _info: Term) -> bool {
    rustler::resource_struct_init!(CounterResource, env);
    true
}

fn new<'a>(env: Env<'a>, _args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let data = CounterResource {
        counter: RelaxedCounter::new(0),
    };
    let resource = ResourceArc::new(data);
    Ok(resource.encode(env))
}

fn get<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let resource: ResourceArc<CounterResource> = args[0].decode()?;
    let counter = &resource.counter;
    Ok(counter.get().encode(env))
}

fn reset<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let resource: ResourceArc<CounterResource> = args[0].decode()?;
    let counter = &resource.counter;
    counter.reset();
    Ok(atoms::ok().encode(env))
}

fn add<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let resource: ResourceArc<CounterResource> = args[0].decode()?;
    let counter = &resource.counter;

    let num1: usize = args[1].decode()?;

    // increment counter
    counter.add(num1);

    Ok(counter.get().encode(env))
}
