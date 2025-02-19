CLIPPY_OPTS := -A clippy::mutable_key_type

fmt:
	cargo fmt --all -- --check
	cd test && cargo fmt --all -- --check

clippy:
	RUSTFLAGS='-F warnings' cargo clippy --all --tests -- ${CLIPPY_OPTS}
	cp -f Cargo.lock test/Cargo.lock && cd test && RUSTFLAGS='-F warnings' cargo clippy --all -- ${CLIPPY_OPTS}

test:
	RUSTFLAGS='-F warnings' RUST_BACKTRACE=full cargo test --all

ci: fmt clippy test security-audit
	git diff --exit-code Cargo.lock

integration:
	bash devtools/ci/integration.sh v0.41.0-rc1

prod: ## Build binary with release profile.
	cargo build --release

security-audit: ## Use cargo-audit to audit Cargo.lock for crates with security vulnerabilities.
	@cargo +nightly install cargo-audit
	cargo audit
	# expecting to see "Success No vulnerable packages found"

.PHONY: test clippy fmt integration ci prod security-audit
