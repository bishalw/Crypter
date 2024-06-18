protocol CryptoRepository {
    func fetchAllCoins() -> AnyPublisher<[CoinModel], Error>
    func fetchCoinDetail(coin: CoinModel) -> AnyPublisher<CoinDetailModel, Error>
    func fetchGlobalData() -> AnyPublisher<MarketDataModel, Error>
}