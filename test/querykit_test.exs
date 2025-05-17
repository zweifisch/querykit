defmodule QuerykitTest do
  use ExUnit.Case
  doctest Querykit

  import Querykit

  test "q sigil with single parameter" do
    assert ~q(select * from users where id = #{1}) ==
             {"select * from users where id = $1", [1]}
  end

  test "q sigil with single expr" do
    assert ~q(select * from users where id = #{1 + 1}) ==
             {"select * from users where id = $1", [2]}
  end

  test "q sigil with string parameter" do
    assert ~q(select * from users where id = #{"foo"}) ==
             {"select * from users where id = $1", ["foo"]}
  end

  test "q sigil with list parameter" do
    assert ~q(select * from users where id in #{[1, 2]}) ==
             {"select * from users where id in $1", [[1, 2]]}
  end

  test "q sigil with boolean parameter" do
    assert ~q(SELECT * FROM users WHERE age > #{18} AND active = #{true}) ==
             {"SELECT * FROM users WHERE age > $1 AND active = $2", [18, true]}
  end

  test "q sigil with multiple parameters" do
    name = "Alice"
    age = 7

    assert ~q(select * from users where name = #{name} and age = #{age}) ==
             {"select * from users where name = $1 and age = $2", [name, age]}
  end

  test "q sigil with insert" do
    name = "Alice"
    age = 25

    assert ~q"INSERT INTO users (name, age) VALUES (#{name}, #{age})" ==
             {"INSERT INTO users (name, age) VALUES ($1, $2)", ["Alice", 25]}
  end

  test "q sigil with no parameters" do
    assert ~q(select * from users) ==
             {"select * from users", []}
  end

  test "q sigil with dynamic paramter" do
    fn1 = fn id -> ~q(select * from users where id = #{id}) end
    assert fn1.(0) == {"select * from users where id = $1", [0]}
  end

  test "q sigil with %" do
    user_id = 42
    prefix = "A"

    assert ~q(select id, name from users where id = #{user_id} and name like #{prefix <> "%"}) ==
             {"select id, name from users where id = $1 and name like $2",
              [user_id, prefix <> "%"]}
  end

  test "q sigil with nil parameter" do
    assert ~q(select * from users where name is #{nil}) ==
             {"select * from users where name is $1", [nil]}
  end

  test "q sigil with special characters" do
    special = ~s(O"'Neil)

    assert ~q(select * from users where name = #{special}) ==
             {"select * from users where name = $1", [special]}
  end

  test "q sigil with subquery" do
    id = 1

    assert ~q"""
           select * from users where id in
           (select user_id from orders where total > #{100} and customer_id = #{id})
           """ ==
             {"""
              select * from users where id in
              (select user_id from orders where total > $1 and customer_id = $2)
              """, [100, 1]}
  end
end
